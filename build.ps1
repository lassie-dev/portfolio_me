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
<meta name="description" content="Lassie - senior full-stack engineer. Commerce platforms, analytics and attribution that reconcile, Android apps that survive real devices, and background services expected never to stop. Available for contract work.">
<meta name="theme-color" content="#FCFCFB" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0D0D0F" media="(prefers-color-scheme: dark)">
<meta property="og:title" content="Lassie - Senior Full-Stack Engineer">
<meta property="og:description" content="Commerce, analytics, Android and always-on backend services. I diagnose before I change anything, and I prove the cause before I ship the fix.">
<meta property="og:type" content="website">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'><rect width='32' height='32' rx='7' fill='%23141416'/><text x='16' y='23' text-anchor='middle' font-family='monospace' font-size='19' font-weight='700' fill='%23E09A5F'>L</text></svg>">
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

# --- warn about unfilled placeholders, e.g. ((N)) or ((X%)) ---
$slots = [regex]::Matches($content, '\(\([^)]{1,40}\)\)') |
         ForEach-Object { $_.Value } |
         Where-Object { $_ -ne '(( ... ))' } |
         Select-Object -Unique
if ($slots) {
  Write-Warning ("Unfilled placeholders still in content.html: " + ($slots -join ', '))
  Write-Warning "Replace these with real figures before deploying."
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $here 'index.html'), ($head + "`n" + $content + $tail), $utf8NoBom)

Write-Host "built index.html"
