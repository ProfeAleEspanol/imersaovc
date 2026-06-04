Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$heroPath = Join-Path $root "assets\hero-vibe-coding.png"
$outDir = Join-Path $root "assets\social"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

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

function Draw-RoundedFill($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, $borderColor = $null, [float]$borderWidth = 2) {
  $path = New-RoundedPath $x $y $w $h $r
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.FillPath($brush, $path)
  $brush.Dispose()
  if ($borderColor -ne $null) {
    $pen = New-Object System.Drawing.Pen($borderColor, $borderWidth)
    $g.DrawPath($pen, $path)
    $pen.Dispose()
  }
  $path.Dispose()
}

function Draw-CoverImage($g, $img, [int]$w, [int]$h) {
  $srcRatio = $img.Width / $img.Height
  $dstRatio = $w / $h
  if ($srcRatio -gt $dstRatio) {
    $srcH = $img.Height
    $srcW = [int]($srcH * $dstRatio)
    $srcX = [int](($img.Width - $srcW) * .62)
    $srcY = 0
  } else {
    $srcW = $img.Width
    $srcH = [int]($srcW / $dstRatio)
    $srcX = 0
    $srcY = [int](($img.Height - $srcH) * .35)
  }
  $src = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcW, $srcH)
  $dst = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $g.DrawImage($img, $dst, $src, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$fontSize, [string]$color, [int]$style = 0, [string]$family = "Segoe UI", [float]$lineHeight = 1.08) {
  $font = New-Object System.Drawing.Font($family, $fontSize, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush((ColorFromHex $color))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Near
  $format.LineAlignment = [System.Drawing.StringAlignment]::Near
  $format.Trimming = [System.Drawing.StringTrimming]::Word
  $format.FormatFlags = 0
  $size = $g.MeasureString($text, $font, [int]$w, $format)
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $size.Height * $lineHeight)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $font.Dispose()
  $brush.Dispose()
  $format.Dispose()
  return $y + ($size.Height * $lineHeight)
}

function Draw-CenteredText($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$fontSize, [string]$color, [int]$style = 0, [string]$family = "Segoe UI", [float]$lineHeight = 1.08) {
  $font = New-Object System.Drawing.Font($family, $fontSize, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush((ColorFromHex $color))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Near
  $format.Trimming = [System.Drawing.StringTrimming]::Word
  $size = $g.MeasureString($text, $font, [int]$w, $format)
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $size.Height * $lineHeight)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $font.Dispose()
  $brush.Dispose()
  $format.Dispose()
  return $y + ($size.Height * $lineHeight)
}

function Draw-Base($g, $hero, [int]$w, [int]$h, [float]$dark = .72) {
  Draw-CoverImage $g $hero $w $h
  $black = [System.Drawing.Color]::FromArgb([int](255 * $dark), 5, 6, 10)
  $g.FillRectangle((New-Object System.Drawing.SolidBrush($black)), 0, 0, $w, $h)
  $cyan = New-Object System.Drawing.SolidBrush((ColorFromHex "#38bdf8" 44))
  $violet = New-Object System.Drawing.SolidBrush((ColorFromHex "#a855f7" 42))
  $yellow = New-Object System.Drawing.SolidBrush((ColorFromHex "#facc15" 36))
  $g.FillEllipse($cyan, $w * .62, -$h * .12, $w * .42, $h * .28)
  $g.FillEllipse($violet, -$w * .20, $h * .70, $w * .48, $h * .26)
  $g.FillEllipse($yellow, $w * .18, -$h * .10, $w * .32, $h * .18)
  $cyan.Dispose(); $violet.Dispose(); $yellow.Dispose()
}

function New-Graphic([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  return @($bmp, $g)
}

$hero = [System.Drawing.Image]::FromFile($heroPath)
$bold = [System.Drawing.FontStyle]::Bold
$regular = [System.Drawing.FontStyle]::Regular
$imersao = "Imers$([char]0x00E3)o"
$imersivo = "Imersivo"
$refugio = "Ref$([char]0x00FA)gio Inema"
$refugioUpper = "REF$([char]0x00DA)GIO INEMA"
$producao = "produ$([char]0x00E7)$([char]0x00E3)o"
$cartao = "cart$([char]0x00E3)o"

# Instagram feed - 1:1
$pair = New-Graphic 1080 1080
$bmp = $pair[0]; $g = $pair[1]
Draw-Base $g $hero 1080 1080 .76
Draw-RoundedFill $g 250 70 580 58 12 (ColorFromHex "#ffffff" 20) (ColorFromHex "#ffffff" 38)
[void](Draw-CenteredText $g "26 A 28 DE JUNHO DE 2026" 260 84 560 25 "#f7f7fb" $bold)
[void](Draw-CenteredText $g $imersivo 90 214 900 112 "#ffffff" $bold)
[void](Draw-CenteredText $g "Vibe Code" 70 330 940 154 "#facc15" $bold)
[void](Draw-CenteredText $g "Do zero ao SaaS com IA em 3 dias" 110 508 860 42 "#e8eaf1" $bold)
Draw-RoundedFill $g 180 634 720 122 14 (ColorFromHex "#ffffff" 18) (ColorFromHex "#facc15" 95)
[void](Draw-CenteredText $g "$refugioUpper - CANELA - RS" 210 662 660 33 "#ffffff" $bold)
[void](Draw-CenteredText $g "Valor promocional: R$ 2.000" 210 710 660 30 "#facc15" $bold)
[void](Draw-CenteredText $g "Construa agentes de IA, dashboard, pagamentos e deploy." 140 820 800 29 "#cfd3dc" $regular)
Draw-RoundedFill $g 330 932 420 64 10 (ColorFromHex "#facc15") $null
[void](Draw-CenteredText $g "GARANTA SUA VAGA" 350 948 380 26 "#080808" $bold)
$bmp.Save((Join-Path $outDir "instagram-feed-1080.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# Reels / TikTok / Stories - 9:16
$pair = New-Graphic 1080 1920
$bmp = $pair[0]; $g = $pair[1]
Draw-Base $g $hero 1080 1920 .80
Draw-RoundedFill $g 76 86 560 58 12 (ColorFromHex "#facc15" 235) $null
[void](Draw-Text $g "OFERTA: DE R$ 3.800 POR R$ 2.000" 100 101 520 24 "#080808" $bold)
[void](Draw-Text $g "26 a 28 de junho de 2026" 76 246 900 56 "#ffffff" $bold)
[void](Draw-Text $g $imersao 76 404 900 112 "#ffffff" $bold)
[void](Draw-Text $g "Vibe Code" 76 520 920 146 "#facc15" $bold)
[void](Draw-Text $g "Do zero ao SaaS com IA em 3 dias" 82 704 850 48 "#e8eaf1" $bold)
Draw-RoundedFill $g 82 870 822 156 16 (ColorFromHex "#ffffff" 18) (ColorFromHex "#ffffff" 42)
[void](Draw-Text $g "LOCAL DO IMERSIVO" 118 900 760 28 "#a7abb7" $bold)
[void](Draw-Text $g $refugio 118 938 760 52 "#facc15" $bold)
[void](Draw-Text $g "Canela - RS" 118 996 760 42 "#ffffff" $bold)
[void](Draw-Text $g "Construa uma plataforma SaaS com agentes de IA, pagamentos, landing page e deploy em $producao." 82 1158 860 39 "#d7dbe5" $regular)
Draw-RoundedFill $g 82 1638 500 74 12 (ColorFromHex "#facc15") $null
[void](Draw-Text $g "GARANTIR VAGA" 122 1658 430 31 "#080808" $bold)
[void](Draw-Text $g "Pix ou $cartao - imersivo presencial" 82 1750 800 28 "#a7abb7" $bold)
$bmp.Save((Join-Path $outDir "reels-tiktok-story-1080x1920.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# LinkedIn feed - 1200x627
$pair = New-Graphic 1200 627
$bmp = $pair[0]; $g = $pair[1]
Draw-Base $g $hero 1200 627 .74
Draw-RoundedFill $g 54 42 332 44 10 (ColorFromHex "#ffffff" 20) (ColorFromHex "#ffffff" 42)
[void](Draw-Text $g "26 A 28 DE JUNHO DE 2026" 72 53 300 20 "#f7f7fb" $bold)
[void](Draw-Text $g $imersao 54 126 640 58 "#ffffff" $bold)
[void](Draw-Text $g "Vibe Code" 54 186 640 70 "#facc15" $bold)
[void](Draw-Text $g "Do zero ao SaaS com IA em 3 dias" 58 284 640 35 "#facc15" $bold)
[void](Draw-Text $g "Construa uma plataforma SaaS funcional com agentes de IA, pagamentos, landing page e deploy." 58 346 615 25 "#d7dbe5" $regular)
Draw-RoundedFill $g 730 108 365 266 18 (ColorFromHex "#ffffff" 18) (ColorFromHex "#facc15" 80)
[void](Draw-Text $g "LOCAL" 762 134 310 22 "#a7abb7" $bold)
[void](Draw-Text $g $refugio 762 170 310 38 "#facc15" $bold)
[void](Draw-Text $g "Canela - RS" 762 218 310 31 "#ffffff" $bold)
[void](Draw-Text $g "Valor promocional" 762 284 310 22 "#a7abb7" $bold)
[void](Draw-Text $g "R$ 2.000" 762 314 310 43 "#ffffff" $bold)
Draw-RoundedFill $g 58 498 346 56 10 (ColorFromHex "#facc15") $null
[void](Draw-Text $g "GARANTA SUA VAGA" 84 512 300 24 "#080808" $bold)
$bmp.Save((Join-Path $outDir "linkedin-feed-1200x627.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

$hero.Dispose()
Write-Host "Criativos gerados em $outDir"
