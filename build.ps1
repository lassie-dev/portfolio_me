# Wraps content.html (the artifact-shaped body) into a standalone, deployable index.html.
# The <title> and <link> tags are lifted out of the content and placed in <head>.
#
#   powershell -ExecutionPolicy Bypass -File build.ps1

$ErrorActionPreference = 'Stop'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$content = Get-Content (Join-Path $here 'content.html') -Raw -Encoding UTF8

# --- lift <title> and <link> out of the body, into the head ---
$titleTag = ''
$m = [regex]::Match($content, '<title>.*?</title>', 'Singleline')
if ($m.Success) {
  $titleTag = $m.Value
  $content  = $content.Remove($m.Index, $m.Length)
}

$linkTags = New-Object System.Collections.Generic.List[string]
$linkRx   = [regex]'<link\b[^>]*>'
foreach ($lm in $linkRx.Matches($content)) { $linkTags.Add($lm.Value) }
$content = $linkRx.Replace($content, '')

# collapse the blank lines the removals left behind
$content = [regex]::Replace($content, '(?m)^[ \t]*\r?\n(?=[ \t]*\r?\n)', '')
$content = $content.TrimStart()

$headExtras = (@($titleTag) + $linkTags | Where-Object { $_ }) -join "`n"

$head = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Lassie - full-stack developer. Online stores, tracking that matches your sales, Android apps that keep running, and servers that stay up. Available for freelance work.">
<meta name="theme-color" content="#FDF6F2" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#1E1620" media="(prefers-color-scheme: dark)">
<meta property="og:title" content="Lassie's Letter">
<meta property="og:description" content="I fix broken systems and build new ones. Stores, tracking, Android, servers.">
<meta property="og:type" content="website">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'><text y='26' font-size='26'>&#127800;</text></svg>">
__HEAD_EXTRAS__
<style>
  html{color-scheme:light dark}
  body{margin:0}
  img{max-width:100%}
  [hidden]{display:none!important}
</style>
</head>
<body>
'@

$head = $head.Replace('__HEAD_EXTRAS__', $headExtras)

$tail = @'

</body>
</html>
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $here 'index.html'), ($head + "`n" + $content + $tail), $utf8NoBom)

Write-Host "built index.html"
