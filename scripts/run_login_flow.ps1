# filepath: scripts/run_login_flow.ps1
# CSRF -> login -> /api/user flow using PowerShell web session and writes readable UTF-8 log
param(
    [string]$LogFile = "console2_login_flow.txt"
)

$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$log = $LogFile
Remove-Item -ErrorAction SilentlyContinue $log

function Log($s) { $s | Out-File -FilePath $log -Append -Encoding utf8 }

Log "=== START LOGIN FLOW $(Get-Date -Format o) ==="

$base = 'http://localhost'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$originHeader = 'http://localhost:8080'

# 1. GET CSRF cookie
Log "-- GET /sanctum/csrf-cookie"
try {
    $r = Invoke-WebRequest -Uri "$base/sanctum/csrf-cookie" -WebSession $session -UseBasicParsing -Method GET -Headers @{ 'Origin' = $originHeader } -ErrorAction Stop
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

# 2. POST /api/login
$loginUrl = "$base/api/login"
$body = @{ email='test@example.com'; password='password' }
Log "-- POST /api/login"
Log "Request body: $(ConvertTo-Json $body -Depth 3)"
try {
    $headers = @{ 'X-XSRF-TOKEN' = $xsrf; 'Accept' = 'application/json'; 'Origin' = $originHeader }
    $resp = Invoke-WebRequest -Uri $loginUrl -Method POST -WebSession $session -Body (ConvertTo-Json $body) -ContentType 'application/json' -Headers $headers -UseBasicParsing -ErrorAction Stop
    Log "Status: $($resp.StatusCode)"
    Log "ResponseHeaders:"; $resp.Headers.GetEnumerator() | ForEach-Object { Log ("$($_.Key): $($_.Value)") }
    Log "Body:"; Log $resp.Content
} catch {
    $err = $_.Exception
    Log "POST login failed: $($err.Message)"
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
    $resp2 = Invoke-WebRequest -Uri "$base/api/user" -Method GET -WebSession $session -Headers @{ 'Accept'='application/json'; 'Origin' = $originHeader } -UseBasicParsing -ErrorAction Stop
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

Log "=== END LOGIN FLOW $(Get-Date -Format o) ==="

# Output log content
Get-Content -Path $log -Raw
