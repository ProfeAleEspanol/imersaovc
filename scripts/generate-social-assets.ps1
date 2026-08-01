Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$heroPath = Join-Path $root "assets\hero-vibe-coding.png"
$usingIdentityImage = $false
$identityDir = Join-Path $root "assets\novaidentidade"
if (Test-Path $identityDir) {
  $identityImage = Get-ChildItem -LiteralPath $identityDir -Filter *.png | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($identityImage) {
    $heroPath = $identityImage.FullName
    $usingIdentityImage = $true
  }
}
$outDir = Join-Path $root "assets\social"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$eventName = "IMERSIVO VIBE CODE"
$title = "Sua ideia pode estar constru\u00EDda em tr$([char]0x00EA)s dias."
$subtitle = "28 a 30 de agosto de 2026 - Ref$([char]0x00FA)gio INEMA - Canela/RS"
$price = "Investimento: R$ 2.497"
$organization = "INEMA"

function ColorFromHex([string]$hex, [int]$alpha = 255) {
  $hex = $hex.TrimStart("#")
  $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
  $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
  $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
  return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
}

function New-RoundedPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Fill-Rounded($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, $borderColor = $null) {
  $path = New-RoundedPath $x $y $w $h $r
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.FillPath($brush, $path)
  $brush.Dispose()
  if ($borderColor -ne $null) {
    $pen = New-Object System.Drawing.Pen($borderColor, 2)
    $g.DrawPath($pen, $path)
    $pen.Dispose()
  }
  $path.Dispose()
}

function Draw-CoverImage($g, $img, [int]$w, [int]$h) {
  $srcRatio = $img.Width / $img.Height
  $dstRatio = $w / $h
  if ($script:usingIdentityImage) {
    $srcH = [int]($img.Height * .52)
    $srcW = [int]($srcH * $dstRatio)
    if ($srcW -gt $img.Width) {
      $srcW = $img.Width
      $srcH = [int]($srcW / $dstRatio)
    }
    $srcX = [int](($img.Width - $srcW) * .62)
    $srcY = [int]($img.Height - $srcH)
  } elseif ($srcRatio -gt $dstRatio) {
    $srcH = $img.Height
    $srcW = [int]($srcH * $dstRatio)
    $srcX = [int](($img.Width - $srcW) * .54)
    $srcY = 0
  } else {
    $srcW = $img.Width
    $srcH = [int]($srcW / $dstRatio)
    $srcX = 0
    $srcY = [int](($img.Height - $srcH) * .42)
  }
  $src = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcW, $srcH)
  $dst = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $g.DrawImage($img, $dst, $src, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$size, [string]$color, [int]$style = 0, [float]$lineHeight = 1.08) {
  $font = New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush((ColorFromHex $color))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Near
  $format.LineAlignment = [System.Drawing.StringAlignment]::Near
  $format.Trimming = [System.Drawing.StringTrimming]::Word
  $measured = $g.MeasureString($text, $font, [int]$w, $format)
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $measured.Height * $lineHeight)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $font.Dispose()
  $brush.Dispose()
  $format.Dispose()
  return $y + ($measured.Height * $lineHeight)
}

function New-Graphic([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  return @($bmp, $g)
}

function Draw-Base($g, $hero, [int]$w, [int]$h) {
  Draw-CoverImage $g $hero $w $h
  $overlay = New-Object System.Drawing.SolidBrush((ColorFromHex "#071a33" 238))
  $g.FillRectangle($overlay, 0, 0, $w, $h)
  $overlay.Dispose()

  $linePen = New-Object System.Drawing.Pen((ColorFromHex "#c9751a" 120), 3)
  $g.DrawLine($linePen, $w * .08, $h * .78, $w * .92, $h * .78)
  $linePen.Dispose()

  Fill-Rounded $g ($w * .08) ($h * .08) ($w * .24) 52 6 (ColorFromHex "#fffaf0" 26) (ColorFromHex "#fffaf0" 54)
  [void](Draw-Text $g $organization ($w * .10) (($h * .08) + 13) ($w * .20) 22 "#fffaf0" ([System.Drawing.FontStyle]::Bold))
}

function Draw-Social([int]$w, [int]$h, [string]$fileName, [float]$titleSize, [float]$left, [float]$top, [float]$textWidth) {
  $pair = New-Graphic $w $h
  $bmp = $pair[0]
  $g = $pair[1]
  Draw-Base $g $hero $w $h
  [void](Draw-Text $g $eventName $left $top $textWidth 28 "#c9751a" ([System.Drawing.FontStyle]::Bold))
  $next = Draw-Text $g $title $left ($top + 58) $textWidth $titleSize "#fffaf0" ([System.Drawing.FontStyle]::Bold)
  $next = Draw-Text $g $subtitle $left ($next + 22) $textWidth 30 "#fff1d9" ([System.Drawing.FontStyle]::Bold)
  $priceY = [Math]::Min(($next + 28), ($h - 106))
  Fill-Rounded $g $left $priceY ($textWidth * .70) 70 6 (ColorFromHex "#c9751a") $null
  [void](Draw-Text $g $price ($left + 24) ($priceY + 20) ($textWidth * .64) 26 "#0b1d3a" ([System.Drawing.FontStyle]::Bold))
  $bmp.Save((Join-Path $outDir $fileName), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
}

$hero = [System.Drawing.Image]::FromFile($heroPath)
Draw-Social 1200 627 "linkedin-feed-1200x627.png" 62 72 82 760
Draw-Social 1080 1080 "instagram-feed-1080.png" 78 74 164 850
Draw-Social 1080 1920 "reels-tiktok-story-1080x1920.png" 82 74 390 850
$hero.Dispose()

Write-Host "Criativos gerados em $outDir"
