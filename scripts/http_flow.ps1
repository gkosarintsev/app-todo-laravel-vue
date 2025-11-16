$log = Join-Path (Get-Location) 'console.txt'
Add-Content -Path $log -Value "=== HTTP FLOW SIMPLE START $(Get-Date) ==="

$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Common headers to simulate SPA origin
$commonHeaders = @{ 'Origin' = 'http://localhost:8080'; 'X-Requested-With' = 'XMLHttpRequest'; 'Accept' = 'application/json' }

# 1) CSRF
Add-Content -Path $log -Value '-> GET /sanctum/csrf-cookie'
try {
    $r = Invoke-WebRequest -Uri 'http://localhost/sanctum/csrf-cookie' -WebSession $s -UseBasicParsing -Headers $commonHeaders -ErrorAction Stop
    Add-Content -Path $log -Value "CSRF Status: $($r.StatusCode)"
    Add-Content -Path $log -Value "CSRF Headers:`n$($r.Headers | Out-String)"
} catch {
    Add-Content -Path $log -Value "CSRF ERROR: $_"
}

# Cookies
Add-Content -Path $log -Value '-> Cookies after CSRF'
foreach ($c in $s.Cookies.GetCookies('http://localhost')) {
    Add-Content -Path $log -Value ("COOKIE: {0}={1}; Domain={2}; Path={3}; HttpOnly={4}; Secure={5}" -f $c.Name,$c.Value,$c.Domain,$c.Path,$c.HttpOnly,$c.Secure)
}

$cookie = $s.Cookies.GetCookies('http://localhost') | Where-Object { $_.Name -eq 'XSRF-TOKEN' }
if ($cookie) {
    $xs = [System.Net.WebUtility]::UrlDecode($cookie.Value)
    Add-Content -Path $log -Value "XSRF_TOKEN_LEN=$($xs.Length)"
} else {
    Add-Content -Path $log -Value 'XSRF cookie not found'
}

Start-Sleep -Milliseconds 300

# 2) Register
Add-Content -Path $log -Value '-> POST /api/register'
$body = @{ name='Test User'; email='test@example.com'; password='password'; password_confirmation='password' }
$json = $body | ConvertTo-Json
try {
    $r2 = Invoke-WebRequest -Uri 'http://localhost/api/register' -Method Post -Body $json -WebSession $s -ContentType 'application/json' -Headers ($commonHeaders + @{ 'X-XSRF-TOKEN' = $xs }) -ErrorAction Stop
    Add-Content -Path $log -Value "REGISTER Status: $($r2.StatusCode)"
    Add-Content -Path $log -Value "REGISTER Headers:`n$($r2.Headers | Out-String)"
    Add-Content -Path $log -Value "REGISTER Content:`n$($r2.Content | Out-String)"
} catch {
    Add-Content -Path $log -Value "REGISTER ERROR: $_"
}

Start-Sleep -Milliseconds 300

# 3) GET /api/user
Add-Content -Path $log -Value '-> GET /api/user'
try {
    $r3 = Invoke-WebRequest -Uri 'http://localhost/api/user' -Method Get -WebSession $s -Headers $commonHeaders -ErrorAction Stop
    Add-Content -Path $log -Value "USER Status: $($r3.StatusCode)"
    Add-Content -Path $log -Value "USER Content:`n$($r3.Content | Out-String)"
} catch {
    Add-Content -Path $log -Value "USER ERROR: $_"
}

Add-Content -Path $log -Value "=== HTTP FLOW SIMPLE END $(Get-Date) ==="

# Print appended part
Get-Content -Path $log -Raw | Select-String -Pattern '=== HTTP FLOW SIMPLE START' -Context 0,200 | Out-Null
Get-Content -Path $log -Raw
