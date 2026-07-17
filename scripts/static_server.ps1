param(
  [Parameter(Mandatory = $true)]
  [string] $Root,
  [int] $Port = 8080
)

$ErrorActionPreference = 'Stop'
$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Serving $resolvedRoot at http://127.0.0.1:$Port/"

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relative = [Uri]::UnescapeDataString(
      $context.Request.Url.AbsolutePath.TrimStart('/')
    )
    $candidate = Join-Path $resolvedRoot $relative
    if (Test-Path -LiteralPath $candidate -PathType Container) {
      $candidate = Join-Path $candidate 'index.html'
    }

    try {
      $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
      if (-not $resolved.StartsWith($resolvedRoot)) {
        throw 'Requested path is outside the preview root.'
      }
      $bytes = [System.IO.File]::ReadAllBytes($resolved)
      $extension = [System.IO.Path]::GetExtension($resolved).ToLowerInvariant()
      $context.Response.ContentType = switch ($extension) {
        '.html' { 'text/html; charset=utf-8' }
        '.js' { 'text/javascript; charset=utf-8' }
        '.json' { 'application/json; charset=utf-8' }
        '.png' { 'image/png' }
        '.mp4' { 'video/mp4' }
        '.wasm' { 'application/wasm' }
        default { 'application/octet-stream' }
      }
      $context.Response.StatusCode = 200
      $context.Response.ContentLength64 = $bytes.Length
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {
      $context.Response.StatusCode = 404
    } finally {
      $context.Response.OutputStream.Close()
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
