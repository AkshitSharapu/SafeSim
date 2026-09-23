$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:8080/")
$listener.Start()
Write-Host "SafeSim Web Runner active on http://127.0.0.1:8080/"

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$mimeMap = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
}

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            if ($request.Url.AbsolutePath -eq "/favicon.ico") {
                $response.StatusCode = 204
                $response.Close()
                continue
            }

            $reqPath = $request.Url.AbsolutePath.TrimStart('/')
            if ([string]::IsNullOrWhiteSpace($reqPath)) {
                $reqPath = "index.html"
            }

            $localPath = Join-Path $baseDir $reqPath
            if (Test-Path $localPath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
                if ($mimeMap.ContainsKey($ext)) {
                    $response.ContentType = $mimeMap[$ext]
                } else {
                    $response.ContentType = "application/octet-stream"
                }
                $bytes = [System.IO.File]::ReadAllBytes($localPath)
                $response.ContentLength64 = $bytes.Length
                if ($request.HttpMethod -ne "HEAD") {
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                }
            } else {
                $response.StatusCode = 404
                $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $reqPath")
                $response.OutputStream.Write($notFound, 0, $notFound.Length)
            }
            $response.Close()
        } catch {
            try { $response.Close() } catch {}
        }
    }
} finally {
    $listener.Stop()
}
