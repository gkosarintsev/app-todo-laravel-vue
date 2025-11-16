# filepath: c:\var\www\app-todo-laravel-vue\scripts\print-as-utf8.ps1
param(
    [switch]$FromFile,
    [string]$InputFile
)

# Всегда выводим UTF-8
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# Если указан файл — читаем файл
if ($FromFile) {
    if (-not (Test-Path $InputFile)) {
        Write-Error "Файл не найден: $InputFile"
        exit 1
    }
    $bytes = [System.IO.File]::ReadAllBytes($InputFile)
}
else {
    # Читаем STDIN как бинарный поток
    $stdin = [System.Console]::OpenStandardInput()
    $ms = New-Object System.IO.MemoryStream
    $stdin.CopyTo($ms)
    $bytes = $ms.ToArray()
}

# Эвристика: проверка на UTF-16LE без BOM — много нулевых байтов на нечётных позициях
function LooksLikeUtf16LeNoBom {
    param([byte[]]$b)
    if ($b.Length -lt 4) { return $false }
    $checkLen = [Math]::Min(200, [int]([Math]::Floor($b.Length/2)*2))
    $zeros = 0
    $pairs = 0
    for ($i = 1; $i -lt $checkLen; $i += 2) {
        $pairs++
        if ($b[$i] -eq 0) { $zeros++ }
    }
    if ($pairs -eq 0) { return $false }
    return ($zeros / $pairs) -ge 0.7
}

# Определение кодировки
function Detect-Encoding {
    param([byte[]]$bytes)

    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return "utf8-bom"
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return "utf16-le"
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return "utf16-be"
    }
    elseif (LooksLikeUtf16LeNoBom $bytes) {
        return "utf16-le"
    }
    else {
        return "utf8"
    }
}

$enc = Detect-Encoding $bytes
Write-Host "Обнаруженная кодировка: $enc"

switch ($enc) {
    "utf8-bom" { $text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3) }
    "utf16-le" { $text = [System.Text.Encoding]::Unicode.GetString($bytes) }
    "utf16-be" { $text = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes) }
    "utf8"     { $text = [System.Text.Encoding]::UTF8.GetString($bytes) }
}

Write-Output ""
Write-Output $text
