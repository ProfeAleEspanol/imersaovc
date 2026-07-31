Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "assets\social\carrossel-ideia-execucao"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$W = 1080
$H = 1080
$M = 82
$fontFamily = "Segoe UI"

function U([string]$escaped) {
  return ('"' + $escaped + '"' | ConvertFrom-Json)
}

$caption = @(
  (U "Sua ideia n\u00e3o precisa de mais conte\u00fado. Precisa de execu\u00e7\u00e3o."),
  "",
  (U "Voc\u00ea j\u00e1 estudou, testou ferramentas, assistiu a aulas e talvez at\u00e9 tenha come\u00e7ado um projeto. Mas se ele ainda n\u00e3o foi constru\u00eddo, talvez o que esteja faltando seja dire\u00e7\u00e3o, acompanhamento e tempo dedicado para executar."),
  "",
  (U "No Imersivo Vibe Code, voc\u00ea aprende enquanto constr\u00f3i. Em tr\u00eas dias presenciais, sua pr\u00f3pria ideia se transforma em uma primeira vers\u00e3o funcional e constru\u00edda."),
  "",
  "28, 29 e 30 de agosto de 2026",
  (U "Ref\u00fagio INEMA - Canela/RS"),
  "Somente 10 participantes",
  "",
  (U "Comente IMERSIVO para receber as informa\u00e7\u00f5es.")
) -join [Environment]::NewLine

$slides = @(
  @{
    headline = (U "Quantas ideias\nvoc\u00ea j\u00e1 deixou\nesperando?")
    sub = (U "Anotadas, salvas, iniciadas... mas ainda sem conclus\u00e3o.")
  },
  @{
    headline = (U "Voc\u00ea estudou.\nTestou ferramentas.\nAssistiu a aulas.")
    sub = (U "Talvez at\u00e9 tenha come\u00e7ado um projeto.")
    punch = (U "Mas ele ainda n\u00e3o foi constru\u00eddo.")
  },
  @{
    headline = (U "Talvez o problema n\u00e3o seja falta de conhecimento.")
    statementA = (U "Sua ideia n\u00e3o precisa de mais conte\u00fado.")
    statementB = (U "Precisa de execu\u00e7\u00e3o.")
    sub = (U "Dire\u00e7\u00e3o, acompanhamento e tempo dedicado mudam o resultado.")
  },
  @{
    headline = (U "Com intelig\u00eancia artificial, criar ficou mais acess\u00edvel.")
    sub = (U "Mas existe uma diferen\u00e7a entre:")
    left = "ter uma ideia"
    right = (U "transform\u00e1-la em um produto funcional")
  },
  @{
    eyebrow = "IMERSIVO VIBE CODE"
    headline = (U "Voc\u00ea aprende\nenquanto constr\u00f3i.")
    sub = (U "Durante tr\u00eas dias presenciais, sua pr\u00f3pria ideia se transforma em uma primeira vers\u00e3o funcional e constru\u00edda.")
  },
  @{
    headline = (U "Voc\u00ea n\u00e3o precisa ter experi\u00eancia em programa\u00e7\u00e3o.")
    sub = "Precisa chegar com:"
    bullets = @(
      "uma ideia;",
      "um problema real;",
      "um processo que deseja transformar;",
      (U "ou um projeto que ainda n\u00e3o conseguiu concluir.")
    )
  },
  @{
    headline = (U "Traga uma ideia.\nSaia com um produto constru\u00eddo.")
    date = "28, 29 e 30 de agosto de 2026"
    venue = (U "Ref\u00fagio INEMA - Canela/RS")
    seats = "Somente 10 participantes"
    cta = (U "Comente IMERSIVO para receber as informa\u00e7\u00f5es.")
  }
)

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

function Fill-Rounded($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, $borderColor = $null, [float]$borderWidth = 2) {
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

function Stroke-Line($g, [float]$x1, [float]$y1, [float]$x2, [float]$y2, [string]$color, [float]$width = 2, [int]$alpha = 255) {
  $pen = New-Object System.Drawing.Pen((ColorFromHex $color $alpha), $width)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($pen, $x1, $y1, $x2, $y2)
  $pen.Dispose()
}

function New-Graphic([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $bmp.SetResolution(144, 144)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  return @($bmp, $g)
}

function Get-Font([float]$size, [bool]$bold = $false) {
  $style = [System.Drawing.FontStyle]::Regular
  if ($bold) {
    $style = [System.Drawing.FontStyle]::Bold
  }
  return New-Object System.Drawing.Font($fontFamily, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$size, [string]$color, [bool]$bold = $false, [string]$align = "Near") {
  $font = Get-Font $size $bold
  $brush = New-Object System.Drawing.SolidBrush((ColorFromHex $color))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::$align
  $format.LineAlignment = [System.Drawing.StringAlignment]::Near
  $format.Trimming = [System.Drawing.StringTrimming]::Word
  $measured = $g.MeasureString($text, $font, [int]$w, $format)
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, ($measured.Height + 12))
  $g.DrawString($text, $font, $brush, $rect, $format)
  $font.Dispose()
  $brush.Dispose()
  $format.Dispose()
  return $y + $measured.Height + 12
}

function Draw-TextInRect($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, [float]$size, [string]$color, [bool]$bold = $false, [string]$align = "Near", [string]$valign = "Center") {
  $font = Get-Font $size $bold
  $brush = New-Object System.Drawing.SolidBrush((ColorFromHex $color))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::$align
  $format.LineAlignment = [System.Drawing.StringAlignment]::$valign
  $format.Trimming = [System.Drawing.StringTrimming]::Word
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $h)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $font.Dispose()
  $brush.Dispose()
  $format.Dispose()
}

function Draw-Base($g, [bool]$dark = $false) {
  if ($dark) {
    $g.Clear((ColorFromHex "#071a33"))
    Stroke-Line $g 718 112 996 112 "#c9751a" 4 180
    Stroke-Line $g 82 930 998 930 "#fffaf0" 2 32
  } else {
    $g.Clear((ColorFromHex "#fffaf0"))
    Stroke-Line $g 710 110 998 110 "#c9751a" 4 180
    Stroke-Line $g 82 930 998 930 "#0b1d3a" 2 22
  }
}

function Draw-Brand($g, [bool]$dark = $false) {
  $color = "#0b1d3a"
  $muted = "#6a6256"
  if ($dark) {
    $color = "#fffaf0"
    $muted = "#d9ccba"
  }
  Draw-TextInRect $g "INEMA" $M 64 128 34 25 $color $true
  Draw-TextInRect $g "Imersivo Vibe Code" 212 64 270 34 17 $muted $true
}

function Draw-Note($g, [float]$x, [float]$y) {
  Fill-Rounded $g ($x + 18) ($y + 20) 322 326 8 (ColorFromHex "#0b1d3a" 18)
  Fill-Rounded $g $x $y 322 326 8 (ColorFromHex "#fffaf0") (ColorFromHex "#d9c8b2") 2
  Draw-TextInRect $g "ideia" ($x + 34) ($y + 30) 112 42 26 "#0b1d3a" $true
  Fill-Rounded $g ($x + 202) ($y + 34) 76 30 6 (ColorFromHex "#c9751a")
  Draw-TextInRect $g "aberta" ($x + 214) ($y + 34) 52 30 14 "#0b1d3a" $true "Center"
  for ($i = 0; $i -lt 4; $i++) {
    $yy = $y + 105 + ($i * 44)
    Stroke-Line $g ($x + 34) $yy ($x + 250 - ($i * 18)) $yy "#6a6256" 3 92
  }
  Stroke-Line $g ($x + 34) ($y + 278) ($x + 122) ($y + 278) "#667f72" 5 170
}

function Draw-Checklist($g, [float]$x, [float]$y, [float]$w) {
  $items = @((U "estudou"), (U "testou ferramentas"), (U "assistiu a aulas"), (U "come\u00e7ou um projeto"))
  for ($i = 0; $i -lt $items.Count; $i++) {
    $yy = $y + ($i * 62)
    Fill-Rounded $g $x $yy $w 46 7 (ColorFromHex "#fffaf0") (ColorFromHex "#d9c8b2") 2
    Fill-Rounded $g ($x + 18) ($yy + 14) 18 18 4 (ColorFromHex "#667f72")
    Stroke-Line $g ($x + 22) ($yy + 23) ($x + 28) ($yy + 29) "#fffaf0" 3
    Stroke-Line $g ($x + 28) ($yy + 29) ($x + 36) ($yy + 17) "#fffaf0" 3
    Draw-TextInRect $g $items[$i] ($x + 52) $yy ($w - 70) 46 21 "#0b1d3a" $true
  }
}

function Draw-ExecutionSystem($g) {
  $items = @(
    @{text = (U "dire\u00e7\u00e3o"); x = 86},
    @{text = "acompanhamento"; x = 354},
    @{text = "tempo dedicado"; x = 670}
  )
  foreach ($item in $items) {
    Fill-Rounded $g $item.x 692 236 76 8 (ColorFromHex "#fffaf0" 18) (ColorFromHex "#fffaf0" 48) 2
    Draw-TextInRect $g $item.text ($item.x + 20) 692 196 76 24 "#fffaf0" $true "Center"
  }
  Stroke-Line $g 204 790 494 848 "#c9751a" 4 190
  Stroke-Line $g 472 790 494 848 "#c9751a" 4 190
  Stroke-Line $g 788 790 494 848 "#c9751a" 4 190
  Fill-Rounded $g 338 842 314 86 8 (ColorFromHex "#c9751a")
  Draw-TextInRect $g (U "execu\u00e7\u00e3o") 380 842 230 86 36 "#0b1d3a" $true "Center"
}

function Draw-Compare($g, $left, $right) {
  Fill-Rounded $g 86 568 390 230 8 (ColorFromHex "#fffaf0") (ColorFromHex "#d9c8b2") 2
  Fill-Rounded $g 604 568 390 230 8 (ColorFromHex "#071a33")
  Draw-TextInRect $g $left 130 618 292 96 42 "#0b1d3a" $true "Center"
  Draw-TextInRect $g $right 648 600 304 132 37 "#fffaf0" $true "Center"
  Stroke-Line $g 500 682 580 682 "#667f72" 5 220
  Stroke-Line $g 554 658 580 682 "#667f72" 5 220
  Stroke-Line $g 554 706 580 682 "#667f72" 5 220
}

function Draw-Process($g) {
  $items = @((U "dire\u00e7\u00e3o"), (U "constru\u00e7\u00e3o"), (U "publica\u00e7\u00e3o"))
  for ($i = 0; $i -lt $items.Count; $i++) {
    $x = 86 + ($i * 314)
    Fill-Rounded $g $x 796 270 96 8 (ColorFromHex "#fffaf0" 18) (ColorFromHex "#fffaf0" 48) 2
    Draw-TextInRect $g $items[$i] ($x + 22) 796 226 96 27 "#fffaf0" $true "Center"
  }
  Stroke-Line $g 166 750 914 750 "#c9751a" 4 170
}

function Draw-Bullets($g, [array]$items, [float]$x, [float]$y, [float]$w) {
  for ($i = 0; $i -lt $items.Count; $i++) {
    $yy = $y + ($i * 70)
    Fill-Rounded $g $x $yy $w 52 7 (ColorFromHex "#fffaf0") (ColorFromHex "#d9c8b2") 2
    Fill-Rounded $g ($x + 22) ($yy + 17) 18 18 5 (ColorFromHex "#c9751a")
    Draw-TextInRect $g $items[$i] ($x + 58) $yy ($w - 80) 52 23 "#0b1d3a" $true
  }
}

function Draw-Facts($g, $slide) {
  $facts = @($slide.date, $slide.venue, $slide.seats)
  for ($i = 0; $i -lt $facts.Count; $i++) {
    $yy = 562 + ($i * 76)
    Fill-Rounded $g 86 $yy 908 56 7 (ColorFromHex "#fffaf0" 18) (ColorFromHex "#fffaf0" 48) 2
    Draw-TextInRect $g $facts[$i] 116 $yy 848 56 25 "#fffaf0" $true
  }
}

function Save-Slide($bmp, [string]$name) {
  $path = Join-Path $outDir $name
  if (Test-Path $path) {
    Remove-Item $path -Force
  }
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  return $path
}

$generated = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $slides.Count; $i++) {
  $slide = $slides[$i]
  $index = $i + 1
  $pair = New-Graphic $W $H
  $bmp = $pair[0]
  $g = $pair[1]

  switch ($index) {
    1 {
      Draw-Base $g $false
      Draw-Brand $g $false
      [void](Draw-Text $g $slide.headline 82 178 700 64 "#0b1d3a" $true)
      [void](Draw-Text $g $slide.sub 86 460 610 28 "#263a56")
      Draw-Note $g 640 562
      Fill-Rounded $g 82 858 456 64 8 (ColorFromHex "#071a33")
      Draw-TextInRect $g (U "ideia parada n\u00e3o vira produto") 112 858 396 64 25 "#fffaf0" $true "Center"
    }
    2 {
      Draw-Base $g $false
      Draw-Brand $g $false
      [void](Draw-Text $g $slide.headline 82 164 760 53 "#0b1d3a" $true)
      [void](Draw-Text $g $slide.sub 86 416 680 27 "#263a56")
      Draw-Checklist $g 86 522 620
      Fill-Rounded $g 86 830 760 72 8 (ColorFromHex "#071a33")
      Draw-TextInRect $g $slide.punch 122 830 690 72 31 "#c9751a" $true "Center"
    }
    3 {
      Draw-Base $g $true
      Draw-Brand $g $true
      [void](Draw-Text $g $slide.headline 82 164 820 48 "#fffaf0" $true)
      Fill-Rounded $g 86 372 790 88 8 (ColorFromHex "#fffaf0" 18) (ColorFromHex "#fffaf0" 44) 2
      Draw-TextInRect $g $slide.statementA 120 372 720 88 35 "#fffaf0" $true
      Fill-Rounded $g 86 486 536 82 8 (ColorFromHex "#c9751a")
      Draw-TextInRect $g $slide.statementB 120 486 470 82 40 "#0b1d3a" $true
      [void](Draw-Text $g $slide.sub 90 604 740 26 "#d9ccba")
      Draw-ExecutionSystem $g
    }
    4 {
      Draw-Base $g $false
      Draw-Brand $g $false
      [void](Draw-Text $g $slide.headline 82 164 840 49 "#0b1d3a" $true)
      [void](Draw-Text $g $slide.sub 86 410 720 31 "#263a56")
      Draw-Compare $g $slide.left $slide.right
      Fill-Rounded $g 262 846 556 62 8 (ColorFromHex "#c9751a")
      Draw-TextInRect $g (U "o valor est\u00e1 no processo") 290 846 500 62 27 "#0b1d3a" $true "Center"
    }
    5 {
      Draw-Base $g $true
      Draw-Brand $g $true
      [void](Draw-Text $g $slide.eyebrow 82 176 720 25 "#c9751a" $true)
      [void](Draw-Text $g $slide.headline 82 228 820 62 "#fffaf0" $true)
      [void](Draw-Text $g $slide.sub 86 520 780 30 "#fff1d9")
      Draw-Process $g
    }
    6 {
      Draw-Base $g $false
      Draw-Brand $g $false
      [void](Draw-Text $g $slide.headline 82 160 860 52 "#0b1d3a" $true)
      [void](Draw-Text $g $slide.sub 86 430 700 32 "#263a56" $true)
      Draw-Bullets $g $slide.bullets 86 522 820
      Fill-Rounded $g 86 852 714 64 8 (ColorFromHex "#e6d8c4") (ColorFromHex "#d9c8b2") 2
      Draw-TextInRect $g (U "chegue com mat\u00e9ria-prima para executar") 116 852 650 64 26 "#0b1d3a" $true
    }
    7 {
      Draw-Base $g $true
      Draw-Brand $g $true
      [void](Draw-Text $g $slide.headline 82 174 850 60 "#fffaf0" $true)
      Draw-Facts $g $slide
      Fill-Rounded $g 86 814 908 82 8 (ColorFromHex "#c9751a")
      Draw-TextInRect $g $slide.cta 124 814 832 82 30 "#0b1d3a" $true "Center"
    }
  }

  $fileName = "slide-{0:00}.png" -f $index
  $path = Save-Slide $bmp $fileName
  $generated.Add($path) | Out-Null
  $g.Dispose()
  $bmp.Dispose()
}

$captionPath = Join-Path $outDir "legenda.txt"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($captionPath, $caption, $utf8NoBom)

$thumb = 260
$gap = 20
$previewW = (3 * $thumb) + (4 * $gap)
$previewH = (3 * $thumb) + (4 * $gap)
$previewPair = New-Graphic $previewW $previewH
$preview = $previewPair[0]
$pg = $previewPair[1]
$pg.Clear((ColorFromHex "#efe7d8"))
for ($i = 0; $i -lt $generated.Count; $i++) {
  $img = [System.Drawing.Image]::FromFile($generated[$i])
  $col = $i % 3
  $row = [Math]::Floor($i / 3)
  $x = $gap + ($col * ($thumb + $gap))
  $y = $gap + ($row * ($thumb + $gap))
  $dst = New-Object System.Drawing.Rectangle($x, $y, $thumb, $thumb)
  $pg.DrawImage($img, $dst)
  $img.Dispose()
}
$previewPath = Join-Path $outDir "preview-grid.png"
if (Test-Path $previewPath) {
  Remove-Item $previewPath -Force
}
$preview.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
$pg.Dispose()
$preview.Dispose()

Write-Host "Carrossel 1:1 gerado em $outDir"
Write-Host "Slides: $($generated.Count)"
Write-Host "Legenda: $captionPath"
Write-Host "Preview: $previewPath"
