$log = Join-Path (Get-Location) 'console.txt'
Remove-Item -Path $log -ErrorAction SilentlyContinue
Add-Content -Path $log -Value "=== START FLOW $(Get-Date) ==="

Add-Content -Path $log -Value "=== DOCKER: down ==="
docker-compose down 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Add-Content -Path $log -Value "=== DOCKER: up -d --build ==="
docker-compose up -d --build 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Start-Sleep -Seconds 8

Add-Content -Path $log -Value "=== LARAVEL: config:clear & cache:clear ==="
docker-compose exec backend bash -lc "cd /var/www/html && php artisan config:clear && php artisan cache:clear" 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Add-Content -Path $log -Value "=== LARAVEL: migrate:fresh --seed ==="
docker-compose exec backend bash -lc "cd /var/www/html && php artisan migrate:fresh --seed --force" 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Add-Content -Path $log -Value "=== HTTP FLOW: CSRF -> register -> user ==="
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# CSRF
Add-Content -Path $log -Value "-> GET /sanctum/csrf-cookie"
try {
    $resp = Invoke-WebRequest -Uri 'http://localhost/sanctum/csrf-cookie' -WebSession $s -UseBasicParsing -Verbose 4>&1
    $status = $resp.StatusCode -or 'N/A'
    Add-Content -Path $log -Value "CSRF Status: $status"
    Add-Content -Path $log -Value "CSRF Headers: $($resp.Headers | Out-String)"
    Add-Content -Path $log -Value "CSRF RawContentLength: $($resp.RawContentLength)"
} catch {
    Add-Content -Path $log -Value "CSRF ERROR: $_"
}

Start-Sleep -Milliseconds 500

# Cookies
Add-Content -Path $log -Value "-> Cookies after CSRF"
$s.Cookies.GetCookies('http://localhost') | ForEach-Object { Add-Content -Path $log -Value ("COOKIE: $($_.Name)=$($_.Value) Domain=$($_.Domain) Path=$($_.Path) Secure=$($_.Secure) HttpOnly=$($_.HttpOnly)") }

$cookie = $s.Cookies.GetCookies('http://localhost') | Where-Object { $_.Name -eq 'XSRF-TOKEN' }
if ($cookie) {
    $xsrf = [System.Net.WebUtility]::UrlDecode($cookie.Value)
    Add-Content -Path $log -Value "XSRF_TOKEN_LEN=$(if ($xsrf) { $xsrf.Length } else { 0 })"
} else {
    Add-Content -Path $log -Value "XSRF cookie not found"
}

Start-Sleep -Milliseconds 250

# Register (Accept: application/json)
Add-Content -Path $log -Value "-> POST /api/register"
$body = @{ name='Test User'; email='test@example.com'; password='password' } | ConvertTo-Json
try {
    $r2 = Invoke-WebRequest -Uri 'http://localhost/api/register' -Method Post -Body $body -WebSession $s -ContentType 'application/json' -Headers @{ 'X-XSRF-TOKEN' = $xsrf; 'Accept' = 'application/json' } -Verbose 4>&1
    Add-Content -Path $log -Value "REGISTER Status: $($r2.StatusCode)"
    Add-Content -Path $log -Value "REGISTER Headers: $($r2.Headers | Out-String)"
    Add-Content -Path $log -Value "REGISTER Content: $($r2.Content | Out-String)"
} catch {
    Add-Content -Path $log -Value "REGISTER ERROR: $_"
}

Start-Sleep -Milliseconds 250

# Get user (Accept: application/json)
Add-Content -Path $log -Value "-> GET /api/user"
try {
    $r3 = Invoke-WebRequest -Uri 'http://localhost/api/user' -Method Get -WebSession $s -Headers @{ 'Accept'='application/json' } -Verbose 4>&1
    Add-Content -Path $log -Value "USER Status: $($r3.StatusCode)"
    Add-Content -Path $log -Value "USER Headers: $($r3.Headers | Out-String)"
    Add-Content -Path $log -Value "USER Content: $($r3.Content | Out-String)"
} catch {
    Add-Content -Path $log -Value "USER ERROR: $_"
}

# Append Laravel logs for debugging
Add-Content -Path $log -Value "=== Laravel log tail ==="
docker-compose exec backend bash -lc "tail -n 200 storage/logs/laravel.log || true" 2>&1 | Out-File -FilePath $log -Append -Encoding utf8

Add-Content -Path $log -Value "=== END FLOW $(Get-Date) ==="

# Output the log
Get-Content $log -Raw
