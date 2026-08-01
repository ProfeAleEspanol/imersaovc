Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "assets\social\campanha-do-rascunho-ao-ar"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$fontFamily = "Segoe UI"
$ink = "#0b1d3a"
$muted = "#6a6256"
$paper = "#fffaf0"
$paper2 = "#efe7d8"
$dark = "#071a33"
$yellow = "#c9751a"
$teal = "#667f72"
$blue = "#0e3157"
$line = "#d9c8b2"

function U([string]$escaped) {
  return ('"' + $escaped + '"' | ConvertFrom-Json)
}

function T([string]$escaped) {
  return [System.Text.RegularExpressions.Regex]::Unescape($escaped)
}

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

function New-Slide([int]$w, [int]$h, [string]$theme = "light") {
  $pair = New-Graphic $w $h
  $bmp = $pair[0]
  $g = $pair[1]
  if ($theme -eq "dark") {
    $g.Clear((ColorFromHex $dark))
    Stroke-Line $g ($w - 376) 112 ($w - 82) 112 $yellow 4 180
    Stroke-Line $g 82 ($h - 150) ($w - 82) ($h - 150) "#fffaf0" 2 32
  } else {
    $g.Clear((ColorFromHex $paper))
    Stroke-Line $g ($w - 376) 112 ($w - 82) 112 $yellow 4 180
    Stroke-Line $g 82 ($h - 150) ($w - 82) ($h - 150) $ink 2 22
  }
  return @($bmp, $g)
}

function Draw-Brand($g, [int]$w, [bool]$darkTheme = $false) {
  $brand = $ink
  $sub = "#6a6256"
  if ($darkTheme) {
    $brand = "#fffaf0"
    $sub = "#d9ccba"
  }
  Draw-TextInRect $g "INEMA" 82 64 128 34 25 $brand $true
  Draw-TextInRect $g "Imersivo Vibe Code" 212 64 270 34 17 $sub $true
}

function Save-Image($bmp, [string]$path) {
  $dir = Split-Path -Parent $path
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  if (Test-Path $path) {
    Remove-Item $path -Force
  }
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Write-TextFile([string]$path, [string]$content) {
  $dir = Split-Path -Parent $path
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Draw-Stack($g, [float]$x, [float]$y, [float]$scale = 1) {
  Fill-Rounded $g ($x + 28 * $scale) ($y + 34 * $scale) (330 * $scale) (248 * $scale) (8 * $scale) (ColorFromHex $ink 18)
  Fill-Rounded $g ($x + 14 * $scale) ($y + 18 * $scale) (330 * $scale) (248 * $scale) (8 * $scale) (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
  Fill-Rounded $g $x $y (330 * $scale) (248 * $scale) (8 * $scale) (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
  Draw-TextInRect $g "rascunho" ($x + 32 * $scale) ($y + 26 * $scale) (152 * $scale) (42 * $scale) (24 * $scale) $ink $true
  for ($i = 0; $i -lt 4; $i++) {
    $yy = $y + (96 + ($i * 34)) * $scale
    Stroke-Line $g ($x + 34 * $scale) $yy ($x + (266 - ($i * 16)) * $scale) $yy $muted (3 * $scale) 80
  }
  Fill-Rounded $g ($x + 218 * $scale) ($y + 28 * $scale) (78 * $scale) (30 * $scale) (6 * $scale) (ColorFromHex $yellow)
  Draw-TextInRect $g "aberto" ($x + 228 * $scale) ($y + 28 * $scale) (58 * $scale) (30 * $scale) (13 * $scale) $ink $true "Center"
}

function Draw-ProductWindow($g, [float]$x, [float]$y, [float]$w, [float]$h, [bool]$darkCard = $false) {
  $fill = "#fffaf0"
  $border = $line
  $text = $ink
  if ($darkCard) {
    $fill = "#112b49"
    $border = "#48607a"
    $text = "#fffaf0"
  }
  Fill-Rounded $g $x $y $w $h 8 (ColorFromHex $fill) (ColorFromHex $border) 2
  Fill-Rounded $g ($x + 22) ($y + 22) 12 12 6 (ColorFromHex $yellow)
  Fill-Rounded $g ($x + 44) ($y + 22) 12 12 6 (ColorFromHex $teal)
  Fill-Rounded $g ($x + 66) ($y + 22) 12 12 6 (ColorFromHex $blue)
  Stroke-Line $g ($x + 24) ($y + 72) ($x + $w - 34) ($y + 72) $border 2 160
  Draw-TextInRect $g "produto construído" ($x + 28) ($y + 94) ($w - 56) 42 24 $text $true
  Fill-Rounded $g ($x + 28) ($y + 154) ($w - 56) 58 8 (ColorFromHex $yellow)
  Draw-TextInRect $g "link no ar" ($x + 54) ($y + 154) ($w - 108) 58 24 $ink $true "Center"
}

function Draw-SeatGrid($g, [float]$x, [float]$y, [bool]$darkTheme = $false) {
  $border = $line
  $fill = "#fffaf0"
  $text = $ink
  if ($darkTheme) {
    $border = "#48607a"
    $fill = "#112b49"
    $text = "#fffaf0"
  }
  for ($i = 0; $i -lt 10; $i++) {
    $col = $i % 5
    $row = [Math]::Floor($i / 5)
    $xx = $x + ($col * 84)
    $yy = $y + ($row * 84)
    $color = $fill
    if ($i -lt 3) {
      $color = $yellow
    }
    Fill-Rounded $g $xx $yy 60 60 8 (ColorFromHex $color) (ColorFromHex $border) 2
  }
  Draw-TextInRect $g "turma pequena" $x ($y + 190) 420 38 24 $text $true "Center"
}

function Draw-ThreeStep($g, [float]$x, [float]$y, [bool]$darkTheme = $false) {
  $labels = @((U "dire\u00e7\u00e3o"), (U "constru\u00e7\u00e3o"), (U "publica\u00e7\u00e3o"))
  $fill = "#fffaf0"
  $border = $line
  $text = $ink
  if ($darkTheme) {
    $fill = "#112b49"
    $border = "#48607a"
    $text = "#fffaf0"
  }
  for ($i = 0; $i -lt 3; $i++) {
    $xx = $x + ($i * 250)
    Fill-Rounded $g $xx $y 210 80 8 (ColorFromHex $fill) (ColorFromHex $border) 2
    Draw-TextInRect $g $labels[$i] ($xx + 18) $y 174 80 24 $text $true "Center"
    if ($i -lt 2) {
      Stroke-Line $g ($xx + 218) ($y + 40) ($xx + 246) ($y + 40) $teal 4 210
    }
  }
}

function Draw-LeadBadge($g, [float]$x, [float]$y, [float]$w) {
  Fill-Rounded $g $x $y $w 72 8 (ColorFromHex $yellow)
  Draw-TextInRect $g (U "Comente IMERSIVO") ($x + 28) $y ($w - 56) 72 30 $ink $true "Center"
}

function Draw-PreviewGrid([string]$folder, [string[]]$files, [int]$thumbW, [int]$thumbH, [int]$cols, [string]$name) {
  $gap = 20
  $rows = [Math]::Ceiling($files.Count / $cols)
  $w = ($cols * $thumbW) + (($cols + 1) * $gap)
  $h = ($rows * $thumbH) + (($rows + 1) * $gap)
  $pair = New-Graphic $w $h
  $bmp = $pair[0]
  $g = $pair[1]
  $g.Clear((ColorFromHex "#efe7d8"))
  for ($i = 0; $i -lt $files.Count; $i++) {
    $img = [System.Drawing.Image]::FromFile($files[$i])
    $col = $i % $cols
    $row = [Math]::Floor($i / $cols)
    $x = $gap + ($col * ($thumbW + $gap))
    $y = $gap + ($row * ($thumbH + $gap))
    $dst = New-Object System.Drawing.Rectangle($x, $y, $thumbW, $thumbH)
    $g.DrawImage($img, $dst)
    $img.Dispose()
  }
  Save-Image $bmp (Join-Path $folder $name)
  $g.Dispose()
  $bmp.Dispose()
}

$campaignDoc = @(
  "# Campanha Visual - Do rascunho ao ar",
  "",
  "## Ideia central",
  "",
  (T "O Imersivo Vibe Code n\u00e3o vende mais conte\u00fado. Vende o ambiente, o m\u00e9todo e o acompanhamento para transformar uma ideia parada em uma primeira vers\u00e3o funcional e constru\u00edda."),
  "",
  "## Linha criativa",
  "",
  "Do rascunho ao ar.",
  "",
  "## Promessa",
  "",
  (T "Em tr\u00eas dias presenciais, a pessoa sai do rascunho com clareza, constru\u00e7\u00e3o acompanhada e uma primeira vers\u00e3o constru\u00edda."),
  "",
  (T "## Mec\u00e2nica de lead"),
  "",
  "CTA principal: Comente IMERSIVO.",
  "",
  "Fluxo sugerido de resposta por DM:",
  "",
  (T "1. Vi seu coment\u00e1rio no post do Imersivo. Voc\u00ea j\u00e1 tem uma ideia ou projeto em mente?"),
  (T "2. Hoje ela est\u00e1 em que fase: rascunho, projeto iniciado ou processo manual?"),
  (T "3. Quer que eu te envie as informa\u00e7\u00f5es da turma de 28, 29 e 30 de agosto no Ref\u00fagio INEMA?"),
  "",
  (T "## Sequ\u00eancia de conte\u00fado"),
  "",
  (T "1. Diagn\u00f3stico: mostra o custo da ideia parada."),
  (T "2. Transforma\u00e7\u00e3o: mostra como a ideia avan\u00e7a em tr\u00eas dias."),
  (T "3. Convite: apresenta escassez real, local, data e perfil de participante."),
  (T "4. Stories: repete a pergunta de qualifica\u00e7\u00e3o e puxa coment\u00e1rio/DM."),
  "",
  (T "## Dire\u00e7\u00e3o visual"),
  "",
  (T "Editorial, premium e humana. Fundo creme quente ou azul-marinho profundo, tipografia forte, poucos elementos, detalhes em \u00e2mbar, linhas finas e composi\u00e7\u00f5es que lembram mesa de trabalho, rascunho, produto constru\u00eddo e ambiente presencial em Canela. Sem imagens futuristas gen\u00e9ricas, sem brilho excessivo e sem textura de IA.")
) -join [Environment]::NewLine

$legendas = @(
  "# Legendas da Campanha",
  "",
  (T "## Post 01 - Diagn\u00f3stico"),
  "",
  (T "Sua ideia n\u00e3o precisa de mais conte\u00fado. Precisa de execu\u00e7\u00e3o."),
  "",
  (T "Voc\u00ea j\u00e1 estudou, testou ferramentas e talvez at\u00e9 tenha come\u00e7ado alguma coisa. Mas se ainda n\u00e3o existe um projeto constru\u00eddo, o problema provavelmente n\u00e3o \u00e9 ferramenta."),
  "",
  (T "\u00c9 dire\u00e7\u00e3o. Escopo. Tempo protegido. Acompanhamento."),
  "",
  (T "No Imersivo Vibe Code, o aprendizado acontece enquanto voc\u00ea constr\u00f3i a sua pr\u00f3pria ideia."),
  "",
  (T "Comente IMERSIVO para receber as informa\u00e7\u00f5es."),
  "",
  (T "## Post 02 - Transforma\u00e7\u00e3o"),
  "",
  (T "Tr\u00eas dias podem n\u00e3o terminar uma empresa inteira."),
  "",
  (T "Mas podem tirar uma ideia do rascunho e colocar uma primeira vers\u00e3o funcional no ar."),
  "",
  (T "Dia a dia, voc\u00ea define o escopo, constr\u00f3i a solu\u00e7\u00e3o e publica uma vers\u00e3o acess\u00edvel para testar, apresentar e evoluir."),
  "",
  (T "Comente IMERSIVO para receber as informa\u00e7\u00f5es."),
  "",
  "## Post 03 - Convite",
  "",
  (T "N\u00e3o \u00e9 uma turma grande."),
  "",
  (T "S\u00e3o somente 10 participantes porque cada projeto precisa de dire\u00e7\u00e3o, acompanhamento e tempo real de execu\u00e7\u00e3o."),
  "",
  "28, 29 e 30 de agosto de 2026",
  (T "Ref\u00fagio INEMA - Canela/RS"),
  "",
  "Traga uma ideia. Saia com um produto construído.",
  "",
  (T "Comente IMERSIVO para receber as informa\u00e7\u00f5es."),
  "",
  "## Stories",
  "",
  "Use os stories para abrir conversa:",
  "",
  (T "Voc\u00ea tem uma ideia parada?"),
  "O que falta para ela virar produto?",
  "Comente IMERSIVO ou responda este story."
) -join [Environment]::NewLine

Write-TextFile (Join-Path $outDir "campanha.md") $campaignDoc
Write-TextFile (Join-Path $outDir "legendas.md") $legendas

# Post 01: Diagnostico
$post1 = Join-Path $outDir "post-01-diagnostico"
$post1Files = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -le 7; $i++) {
  $theme = "light"
  if ($i -eq 3 -or $i -eq 7) { $theme = "dark" }
  $pair = New-Slide 1080 1080 $theme
  $bmp = $pair[0]
  $g = $pair[1]
  Draw-Brand $g 1080 ($theme -eq "dark")
  switch ($i) {
    1 {
      [void](Draw-Text $g (U "Sua ideia n\u00e3o precisa de mais conte\u00fado.") 82 174 840 58 $ink $true)
      Fill-Rounded $g 82 430 608 82 8 (ColorFromHex $yellow)
      Draw-TextInRect $g (U "Precisa de execu\u00e7\u00e3o.") 122 430 528 82 42 $ink $true
      Draw-Stack $g 650 618 .9
      [void](Draw-Text $g (U "O primeiro passo n\u00e3o \u00e9 consumir mais uma aula. \u00c9 transformar o que voc\u00ea j\u00e1 sabe em algo constru\u00eddo.") 86 650 486 29 $muted)
    }
    2 {
      [void](Draw-Text $g (U "A ideia parada parece produtiva.") 82 174 790 56 $ink $true)
      [void](Draw-Text $g (U "Ela fica em notas, prints, ferramentas salvas e conversas que nunca viram uma primeira vers\u00e3o.") 86 390 780 31 $muted)
      Draw-Stack $g 116 624 .86
      Fill-Rounded $g 526 660 360 76 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "sem escopo") 560 660 292 76 30 $ink $true "Center"
      Fill-Rounded $g 526 760 360 76 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "sem publica\u00e7\u00e3o") 560 760 292 76 30 $ink $true "Center"
    }
    3 {
      [void](Draw-Text $g (U "Talvez n\u00e3o falte conhecimento.") 82 174 820 54 "#fffaf0" $true)
      [void](Draw-Text $g (U "Falte um ambiente onde voc\u00ea tenha clareza do que fazer primeiro e algu\u00e9m acompanhando a execu\u00e7\u00e3o.") 86 390 780 31 "#e2d7c8")
      Fill-Rounded $g 86 652 270 78 8 (ColorFromHex "#112b49") (ColorFromHex "#48607a") 2
      Fill-Rounded $g 406 652 270 78 8 (ColorFromHex "#112b49") (ColorFromHex "#48607a") 2
      Fill-Rounded $g 726 652 270 78 8 (ColorFromHex "#112b49") (ColorFromHex "#48607a") 2
      Draw-TextInRect $g (U "dire\u00e7\u00e3o") 110 652 222 78 27 "#fffaf0" $true "Center"
      Draw-TextInRect $g "acompanhamento" 430 652 222 78 25 "#fffaf0" $true "Center"
      Draw-TextInRect $g "tempo dedicado" 750 652 222 78 25 "#fffaf0" $true "Center"
      Stroke-Line $g 220 764 540 830 $yellow 4 170
      Stroke-Line $g 540 764 540 830 $yellow 4 170
      Stroke-Line $g 860 764 540 830 $yellow 4 170
      Fill-Rounded $g 360 824 360 78 8 (ColorFromHex $yellow)
      Draw-TextInRect $g (U "execu\u00e7\u00e3o") 400 824 280 78 36 $ink $true "Center"
    }
    4 {
      [void](Draw-Text $g (U "A pergunta n\u00e3o \u00e9:\nqual ferramenta usar?") 82 174 820 54 $ink $true)
      [void](Draw-Text $g (U "A pergunta \u00e9: qual problema merece virar produto primeiro?") 86 430 740 34 $muted)
      Fill-Rounded $g 86 646 392 142 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g "ferramenta" 126 646 312 142 36 $muted $true "Center"
      Fill-Rounded $g 602 646 392 142 8 (ColorFromHex $dark)
      Draw-TextInRect $g "problema real" 642 646 312 142 36 "#fffaf0" $true "Center"
      Stroke-Line $g 502 716 578 716 $teal 5 230
      Stroke-Line $g 552 692 578 716 $teal 5 230
      Stroke-Line $g 552 740 578 716 $teal 5 230
    }
    5 {
      [void](Draw-Text $g (U "Conte\u00fado sozinho acumula inten\u00e7\u00e3o.") 82 174 840 54 $ink $true)
      [void](Draw-Text $g (U "Execu\u00e7\u00e3o transforma inten\u00e7\u00e3o em evid\u00eancia.") 86 380 780 34 $muted)
      Draw-ThreeStep $g 86 620 $false
      Draw-ProductWindow $g 620 700 342 220 $false
    }
    6 {
      [void](Draw-Text $g (U "O Imersivo foi desenhado para quem j\u00e1 cansou de deixar ideias pela metade.") 82 174 860 50 $ink $true)
      [void](Draw-Text $g (U "Voc\u00ea aprende enquanto constr\u00f3i. O conte\u00fado entra na hora em que o seu produto pede.") 86 454 760 31 $muted)
      Fill-Rounded $g 86 706 820 92 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "menos promessa gen\u00e9rica") 124 706 340 92 29 $muted $true
      Draw-TextInRect $g (U "mais produto no ar") 502 706 340 92 31 $ink $true "Far"
      Stroke-Line $g 466 752 492 752 $teal 4 220
    }
    7 {
      [void](Draw-Text $g (U "Quer descobrir se a sua ideia cabe no Imersivo?") 82 174 820 56 "#fffaf0" $true)
      [void](Draw-Text $g (U "Comente a palavra abaixo e receba as informa\u00e7\u00f5es da turma presencial em Canela.") 86 430 760 31 "#e2d7c8")
      Draw-LeadBadge $g 86 650 640
      [void](Draw-Text $g (U "28, 29 e 30 de agosto de 2026\nRef\u00fagio INEMA - Canela/RS\nSomente 10 participantes") 90 778 760 28 "#fff1d9" $true)
    }
  }
  $path = Join-Path $post1 ("slide-{0:00}.png" -f $i)
  Save-Image $bmp $path
  $post1Files.Add($path) | Out-Null
  $g.Dispose()
  $bmp.Dispose()
}
Draw-PreviewGrid $post1 $post1Files.ToArray() 260 260 3 "preview-grid.png"

# Post 02: Transformacao
$post2 = Join-Path $outDir "post-02-transformacao"
$post2Files = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -le 6; $i++) {
  $theme = "light"
  if ($i -eq 1 -or $i -eq 6) { $theme = "dark" }
  $pair = New-Slide 1080 1080 $theme
  $bmp = $pair[0]
  $g = $pair[1]
  Draw-Brand $g 1080 ($theme -eq "dark")
  switch ($i) {
    1 {
      [void](Draw-Text $g (U "Do rascunho\nao ar.") 82 176 700 76 "#fffaf0" $true)
      [void](Draw-Text $g (U "Tr\u00eas dias presenciais para transformar uma ideia em uma primeira vers\u00e3o funcional e constru\u00edda.") 86 470 760 32 "#fff1d9")
      Draw-ThreeStep $g 86 738 $true
    }
    2 {
      [void](Draw-Text $g (U "Primeiro: a ideia ganha dire\u00e7\u00e3o.") 82 174 820 56 $ink $true)
      [void](Draw-Text $g (U "Problema, p\u00fablico, fun\u00e7\u00e3o principal e escopo. O projeto deixa de ser uma nuvem e vira mapa.") 86 390 780 31 $muted)
      Fill-Rounded $g 86 642 820 150 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "problema real  \u2192  escopo poss\u00edvel  \u2192  primeira vers\u00e3o") 126 642 740 150 34 $ink $true "Center"
    }
    3 {
      [void](Draw-Text $g (U "Depois: o produto come\u00e7a a existir.") 82 174 820 56 $ink $true)
      [void](Draw-Text $g (U "Telas, fluxos, dados e a funcionalidade central que prova valor.") 86 390 740 31 $muted)
      Draw-ProductWindow $g 152 598 776 286 $false
    }
    4 {
      [void](Draw-Text $g (U "Por fim: publicar muda a conversa.") 82 174 820 56 $ink $true)
      [void](Draw-Text $g (U "Com um link no ar, voc\u00ea pode mostrar, testar, vender, validar e evoluir com base em algo concreto.") 86 390 780 31 $muted)
      Fill-Rounded $g 136 646 808 102 8 (ColorFromHex $dark)
      Draw-TextInRect $g "suaideia.app" 170 646 548 102 42 "#fffaf0" $true
      Fill-Rounded $g 740 666 160 62 8 (ColorFromHex $yellow)
      Draw-TextInRect $g "no ar" 764 666 112 62 27 $ink $true "Center"
    }
    5 {
      [void](Draw-Text $g (U "Voc\u00ea n\u00e3o sai com uma pasta de anota\u00e7\u00f5es.") 82 174 850 54 $ink $true)
      [void](Draw-Text $g (U "Sai com uma primeira vers\u00e3o constru\u00edda e uma base para continuar construindo.") 86 420 780 34 $muted)
      Fill-Rounded $g 86 666 400 118 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "menos teoria solta") 126 666 320 118 31 $muted $true "Center"
      Fill-Rounded $g 596 666 400 118 8 (ColorFromHex $yellow)
      Draw-TextInRect $g (U "mais entrega real") 636 666 320 118 31 $ink $true "Center"
    }
    6 {
      [void](Draw-Text $g (U "Se voc\u00ea tem uma ideia parada, este \u00e9 o convite.") 82 174 860 54 "#fffaf0" $true)
      [void](Draw-Text $g (U "28, 29 e 30 de agosto de 2026\nRef\u00fagio INEMA - Canela/RS\nSomente 10 participantes") 86 458 760 31 "#fff1d9" $true)
      Draw-LeadBadge $g 86 730 640
    }
  }
  $path = Join-Path $post2 ("slide-{0:00}.png" -f $i)
  Save-Image $bmp $path
  $post2Files.Add($path) | Out-Null
  $g.Dispose()
  $bmp.Dispose()
}
Draw-PreviewGrid $post2 $post2Files.ToArray() 260 260 3 "preview-grid.png"

# Post 03: Convite
$post3 = Join-Path $outDir "post-03-convite"
$post3Files = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -le 5; $i++) {
  $theme = "light"
  if ($i -eq 1 -or $i -eq 5) { $theme = "dark" }
  $pair = New-Slide 1080 1080 $theme
  $bmp = $pair[0]
  $g = $pair[1]
  Draw-Brand $g 1080 ($theme -eq "dark")
  switch ($i) {
    1 {
      [void](Draw-Text $g (U "N\u00e3o abriremos uma turma grande.") 82 174 820 60 "#fffaf0" $true)
      [void](Draw-Text $g (U "Porque o objetivo n\u00e3o \u00e9 lotar uma sala. \u00c9 acompanhar projetos reais at\u00e9 uma primeira vers\u00e3o constru\u00edda.") 86 412 780 31 "#e2d7c8")
      Draw-SeatGrid $g 190 660 $true
    }
    2 {
      [void](Draw-Text $g (U "Somente 10 participantes.") 82 174 820 64 $ink $true)
      [void](Draw-Text $g (U "Cada pessoa chega com uma ideia, um problema ou um projeto travado. Cada projeto precisa de dire\u00e7\u00e3o.") 86 390 760 31 $muted)
      Draw-SeatGrid $g 190 628 $false
    }
    3 {
      [void](Draw-Text $g (U "Para quem \u00e9?") 82 174 740 64 $ink $true)
      $items = @(
        (U "uma ideia que ainda n\u00e3o saiu do papel"),
        "um processo manual que poderia virar produto",
        "um projeto iniciado e abandonado",
        (U "uma solu\u00e7\u00e3o que precisa ganhar forma")
      )
      for ($j = 0; $j -lt $items.Count; $j++) {
        $yy = 370 + ($j * 94)
        Fill-Rounded $g 86 $yy 820 66 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
        Fill-Rounded $g 116 ($yy + 22) 22 22 6 (ColorFromHex $yellow)
        Draw-TextInRect $g $items[$j] 160 $yy 700 66 26 $ink $true
      }
    }
    4 {
      [void](Draw-Text $g (U "O local tamb\u00e9m faz parte do m\u00e9todo.") 82 174 820 56 $ink $true)
      [void](Draw-Text $g (U "Tr\u00eas dias presenciais no Ref\u00fagio INEMA, em Canela/RS, com foco, troca e execu\u00e7\u00e3o acompanhada.") 86 390 780 31 $muted)
      Fill-Rounded $g 86 650 820 134 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
      Draw-TextInRect $g (U "28, 29 e 30 de agosto de 2026") 126 650 740 60 30 $ink $true "Center"
      Draw-TextInRect $g (U "Ref\u00fagio INEMA - Canela/RS") 126 710 740 58 28 $muted $true "Center"
    }
    5 {
      [void](Draw-Text $g (U "Traga uma ideia.\nSaia com um produto constru\u00eddo.") 82 174 860 60 "#fffaf0" $true)
      [void](Draw-Text $g (U "Imersivo Vibe Code\n28, 29 e 30 de agosto de 2026\nRef\u00fagio INEMA - Canela/RS\nSomente 10 participantes") 86 500 780 31 "#fff1d9" $true)
      Draw-LeadBadge $g 86 792 720
    }
  }
  $path = Join-Path $post3 ("slide-{0:00}.png" -f $i)
  Save-Image $bmp $path
  $post3Files.Add($path) | Out-Null
  $g.Dispose()
  $bmp.Dispose()
}
Draw-PreviewGrid $post3 $post3Files.ToArray() 260 260 3 "preview-grid.png"

# Stories
$stories = Join-Path $outDir "stories"
$storyFiles = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -le 5; $i++) {
  $theme = "light"
  if ($i -eq 3 -or $i -eq 5) { $theme = "dark" }
  $pair = New-Slide 1080 1920 $theme
  $bmp = $pair[0]
  $g = $pair[1]
  Draw-Brand $g 1080 ($theme -eq "dark")
  switch ($i) {
    1 {
      [void](Draw-Text $g (U "Voc\u00ea tem uma ideia parada?") 82 270 840 82 $ink $true)
      [void](Draw-Text $g (U "Se sim, talvez ela n\u00e3o precise de mais uma aula. Talvez precise de execu\u00e7\u00e3o.") 86 620 780 42 $muted)
      Draw-Stack $g 590 1050 1.05
      Draw-LeadBadge $g 86 1540 640
    }
    2 {
      [void](Draw-Text $g (U "O que falta para ela virar produto?") 82 270 840 78 $ink $true)
      $opts = @((U "dire\u00e7\u00e3o"), "tempo", "escopo", "acompanhamento")
      for ($j = 0; $j -lt $opts.Count; $j++) {
        $yy = 700 + ($j * 140)
        Fill-Rounded $g 86 $yy 820 92 8 (ColorFromHex "#fffaf0") (ColorFromHex $line) 2
        Draw-TextInRect $g $opts[$j] 130 $yy 730 92 38 $ink $true
      }
      [void](Draw-Text $g (U "Responda o story ou comente IMERSIVO.") 90 1435 740 38 $muted $true)
    }
    3 {
      [void](Draw-Text $g (U "No Imersivo, voc\u00ea n\u00e3o vem assistir.") 82 270 840 78 "#fffaf0" $true)
      Fill-Rounded $g 86 620 620 96 8 (ColorFromHex $yellow)
      Draw-TextInRect $g (U "vem construir") 126 620 540 96 48 $ink $true
      [void](Draw-Text $g (U "A sua pr\u00f3pria ideia vira o projeto da imers\u00e3o.") 90 820 760 42 "#e2d7c8")
      Draw-ThreeStep $g 86 1230 $true
    }
    4 {
      [void](Draw-Text $g (U "Tr\u00eas dias presenciais.\nSomente 10 participantes.") 82 270 840 76 $ink $true)
      [void](Draw-Text $g (U "Ref\u00fagio INEMA - Canela/RS\n28, 29 e 30 de agosto de 2026") 86 650 760 42 $muted $true)
      Draw-SeatGrid $g 240 1040 $false
      Draw-LeadBadge $g 86 1540 640
    }
    5 {
      [void](Draw-Text $g (U "Do rascunho\nao ar.") 82 292 820 96 "#fffaf0" $true)
      [void](Draw-Text $g (U "Comente IMERSIVO para receber as informa\u00e7\u00f5es da turma.") 90 690 760 45 "#fff1d9")
      Draw-ProductWindow $g 150 1080 780 310 $true
      Fill-Rounded $g 86 1540 760 90 8 (ColorFromHex $yellow)
      Draw-TextInRect $g "IMERSIVO" 126 1540 680 90 48 $ink $true "Center"
    }
  }
  $path = Join-Path $stories ("story-{0:00}.png" -f $i)
  Save-Image $bmp $path
  $storyFiles.Add($path) | Out-Null
  $g.Dispose()
  $bmp.Dispose()
}
Draw-PreviewGrid $stories $storyFiles.ToArray() 180 320 5 "preview-grid.png"

# Campaign overview preview
$allPreviews = @(
  (Join-Path $post1 "preview-grid.png"),
  (Join-Path $post2 "preview-grid.png"),
  (Join-Path $post3 "preview-grid.png"),
  (Join-Path $stories "preview-grid.png")
)
$overviewPair = New-Graphic 1280 1500
$overview = $overviewPair[0]
$og = $overviewPair[1]
$og.Clear((ColorFromHex "#efe7d8"))
Draw-TextInRect $og "Do rascunho ao ar" 50 38 1180 70 42 $ink $true
Draw-TextInRect $og "Campanha visual de lead - Imersivo Vibe Code" 50 104 1180 46 25 $muted $true
$y = 184
foreach ($previewPath in $allPreviews) {
  $img = [System.Drawing.Image]::FromFile($previewPath)
  $ratio = $img.Width / $img.Height
  $targetW = 1180
  $targetH = [int]($targetW / $ratio)
  if ($targetH -gt 300) {
    $targetH = 300
    $targetW = [int]($targetH * $ratio)
  }
  $x = [int]((1280 - $targetW) / 2)
  $dst = New-Object System.Drawing.Rectangle($x, $y, $targetW, $targetH)
  $og.DrawImage($img, $dst)
  $img.Dispose()
  $y += $targetH + 48
}
Save-Image $overview (Join-Path $outDir "preview-campanha.png")
$og.Dispose()
$overview.Dispose()

Write-Host "Campanha gerada em $outDir"
Write-Host "Post 01: $post1"
Write-Host "Post 02: $post2"
Write-Host "Post 03: $post3"
Write-Host "Stories: $stories"
Write-Host "Estrategia: $(Join-Path $outDir "campanha.md")"
Write-Host "Legendas: $(Join-Path $outDir "legendas.md")"
