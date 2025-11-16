# filepath: scripts/run_http_flow.ps1
# Performs CSRF -> register -> /api/user flow using PowerShell web session and writes readable UTF-8 log
param()

$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$log = "console2_flow.txt"
Remove-Item -ErrorAction SilentlyContinue $log

function Log($s) { $s | Out-File -FilePath $log -Append -Encoding utf8 }

Log "=== START HTTP FLOW $(Get-Date -Format o) ==="

$base = 'http://localhost'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1. GET CSRF cookie
Log "-- GET /sanctum/csrf-cookie"
try {
    $r = Invoke-WebRequest -Uri "$base/sanctum/csrf-cookie" -WebSession $session -UseBasicParsing -Method GET -ErrorAction Stop
    Log "Status: $($r.StatusCode)"
    Log "ResponseHeaders:"
    $r.Headers.GetEnumerator() | ForEach-Object { Log ("$($_.Key): $($_.Value)") }
} catch {
    Log "GET csrf failed: $($_.Exception.Message)"
}

# Extract XSRF token from cookie jar
$xsrf = $null
try {
    $cookies = $session.Cookies.GetCookies($base)
    foreach ($c in $cookies) {
        if ($c.Name -eq 'XSRF-TOKEN') { $xsrf = [System.Uri]::UnescapeDataString($c.Value); break }
    }
    Log "XSRF token (len=$($xsrf.Length)): $xsrf"
} catch {
    Log "Cookie read failed: $($_.Exception.Message)"
}

# 2. POST /api/register
$registerUrl = "$base/api/register"
$body = @{ name='Test User'; email='test@example.com'; password='password'; password_confirmation='password' }
Log "-- POST /api/register"
Log "Request body: $(ConvertTo-Json $body -Depth 3)"
try {
    $headers = @{ 'X-XSRF-TOKEN' = $xsrf; 'Accept' = 'application/json' }
    $resp = Invoke-WebRequest -Uri $registerUrl -Method POST -WebSession $session -Body (ConvertTo-Json $body) -ContentType 'application/json' -Headers $headers -UseBasicParsing -ErrorAction Stop
    Log "Status: $($resp.StatusCode)"
    Log "ResponseHeaders:"; $resp.Headers.GetEnumerator() | ForEach-Object { Log ("$($_.Key): $($_.Value)") }
    Log "Body:"; Log $resp.Content
} catch {
    $err = $_.Exception
    Log "POST register failed: $($err.Message)"
    if ($err.Response) {
        try {
            $respBody = $err.Response.GetResponseStream()
            $sr = New-Object System.IO.StreamReader($respBody)
            $text = $sr.ReadToEnd()
            Log "ErrorResponseBody:"; Log $text
        } catch {
            Log "Failed reading error response body: $($_.Exception.Message)"
        }
    }
}

# 3. GET /api/user
Log "-- GET /api/user"
try {
    $resp2 = Invoke-WebRequest -Uri "$base/api/user" -Method GET -WebSession $session -Headers @{ 'Accept'='application/json' } -UseBasicParsing -ErrorAction Stop
    Log "Status: $($resp2.StatusCode)"
    Log "Body:"; Log $resp2.Content
} catch {
    $err = $_.Exception
    Log "GET /api/user failed: $($err.Message)"
    if ($err.Response) {
        try {
            $respBody = $err.Response.GetResponseStream()
            $sr = New-Object System.IO.StreamReader($respBody)
            $text = $sr.ReadToEnd()
            Log "ErrorResponseBody:"; Log $text
        } catch {
            Log "Failed reading error response body: $($_.Exception.Message)"
        }
    }
}

Log "=== END HTTP FLOW $(Get-Date -Format o) ==="

# Output log content
Get-Content -Path $log -Raw

