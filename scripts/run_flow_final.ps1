# Simplified runner that writes to stdout only so external redirection can capture logs
Write-Output "=== START FLOW $(Get-Date) ==="

function Log { param($m) Write-Output $m }

Log "=== DOCKER: down ==="
& docker-compose down 2>&1 | ForEach-Object { Write-Output $_ }

Log "=== DOCKER: up -d --build ==="
& docker-compose up -d --build 2>&1 | ForEach-Object { Write-Output $_ }

Start-Sleep -Seconds 8

Log "=== LARAVEL: config:clear & cache:clear ==="
& docker-compose exec backend bash -lc "cd /var/www/html && php artisan config:clear && php artisan cache:clear" 2>&1 | ForEach-Object { Write-Output $_ }

Log "=== LARAVEL: migrate:fresh --seed ==="
& docker-compose exec backend bash -lc "cd /var/www/html && php artisan migrate:fresh --seed --force" 2>&1 | ForEach-Object { Write-Output $_ }

Start-Sleep -Seconds 2

# HTTP flow using PowerShell WebRequestSession
Log "=== HTTP FLOW: CSRF -> register -> user ==="
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1) CSRF
Log "-> GET /sanctum/csrf-cookie"
try {
    $resp = Invoke-WebRequest -Uri 'http://localhost/sanctum/csrf-cookie' -WebSession $s -UseBasicParsing -Verbose 4>&1
    Log "CSRF Status: $($resp.StatusCode)"
    Log "CSRF Headers:`n$($resp.Headers | Out-String)"
} catch {
    Log "CSRF ERROR: $_"
}

Start-Sleep -Milliseconds 300

# Cookies after CSRF
Log "-> Cookies after CSRF"
$s.Cookies.GetCookies('http://localhost') | ForEach-Object { Log ("COOKIE: $($_.Name)=$($_.Value) Domain=$($_.Domain) Path=$($_.Path) Secure=$($_.Secure) HttpOnly=$($_.HttpOnly)") }
$cookie = $s.Cookies.GetCookies('http://localhost') | Where-Object { $_.Name -eq 'XSRF-TOKEN' }
if ($cookie) { $xsrf = [System.Net.WebUtility]::UrlDecode($cookie.Value); Log "XSRF_TOKEN_LEN=$($xsrf.Length)" } else { Log "XSRF cookie not found" }

Start-Sleep -Milliseconds 300

# 2) Register (with Accept: application/json) — include password_confirmation
Log "-> POST /api/register"
$body = @{ name='Test User'; email='test@example.com'; password='password'; password_confirmation='password' } | ConvertTo-Json
try {
    $r2 = Invoke-WebRequest -Uri 'http://localhost/api/register' -Method Post -Body $body -WebSession $s -ContentType 'application/json' -Headers @{ 'X-XSRF-TOKEN' = $xsrf; 'Accept' = 'application/json' } -Verbose 4>&1
    Log "REGISTER Status: $($r2.StatusCode)"
    Log "REGISTER Headers:`n$($r2.Headers | Out-String)"
    Log "REGISTER Content:`n$($r2.Content | Out-String)"
} catch {
    Log "REGISTER ERROR: $_"
}

Start-Sleep -Milliseconds 300

# 3) GET /api/user
Log "-> GET /api/user"
try {
    $r3 = Invoke-WebRequest -Uri 'http://localhost/api/user' -Method Get -WebSession $s -Headers @{ 'Accept'='application/json' } -Verbose 4>&1
    Log "USER Status: $($r3.StatusCode)"
    Log "USER Headers:`n$($r3.Headers | Out-String)"
    Log "USER Content:`n$($r3.Content | Out-String)"
} catch {
    Log "USER ERROR: $_"
}

# Append laravel log tail
Log "=== Laravel log tail ==="
& docker-compose exec backend bash -lc "tail -n 200 storage/logs/laravel.log || true" 2>&1 | ForEach-Object { Write-Output $_ }

Log "=== END FLOW $(Get-Date) ==="
