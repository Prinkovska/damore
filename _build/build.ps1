# D'AMORE · збірка портфоліо-версії сайту зі статичних блоків (запуск: powershell -ExecutionPolicy Bypass -File build.ps1)
# Бере блоки з ..\..\Site_Shampoo\ і ..\_src\, замінює Cloudinary на локальні файли, посилання – на відносні, і складає сторінки.
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$out  = Split-Path -Parent $here
$src  = Join-Path (Split-Path -Parent $out) 'Site_Shampoo'
$own  = Join-Path $out '_src'
$utf8 = New-Object Text.UTF8Encoding($false)

function Rx($t, $pattern, $repl){ return [regex]::Replace($t, $pattern, $repl) }
$Q = '[^\x27\x22\s]*'          # будь-що, крім лапок і пробілів

function Conv([string]$t, [string]$name){
  $t = $t.Replace("`r`n", "`n")
  # ---- Cloudinary → локальні файли ----
  $map = @(
    @(("https://res\.cloudinary\.com/$Q" + 'bg3video\.jpg'), '@@/assets/img/bg3video.jpg'),
    @(("https://res\.cloudinary\.com/$Q" + 'logo_damore\.png'), '@@/assets/img/logo_damore.png'),
    @(("https://res\.cloudinary\.com/$Q" + 'video3\.mp4'), '@@/assets/video/hero.mp4'),
    @("https://res\.cloudinary\.com/w9airxdm/image/upload/bg\.jpg", '@@/assets/img/hero-bg.jpg'),
    @(("https://res\.cloudinary\.com/$Q" + 'heart_preload\.png'), '@@/assets/img/heart_preload.png'),
    @(("https://res\.cloudinary\.com/$Q" + 'cursor\.png'), '@@/assets/img/cursor.png'),
    @(("https://res\.cloudinary\.com/$Q" + 'reel(\d)\.mp4'), '@@/assets/video/reel$1.mp4'),
    @(("https://res\.cloudinary\.com/$Q" + 'HistoryDamore\.mp4'), '@@/assets/video/history.mp4'),
    @(("https://res\.cloudinary\.com/$Q" + 'Preview\.jpg'), '@@/assets/img/story-preview.jpg'),
    @(("https://res\.cloudinary\.com/$Q" + 'IMG_3709\.jpg'), '@@/assets/img/about-hero.jpg'),
    @(("https://res\.cloudinary\.com/$Q" + 'InShot\.mp4'), '@@/assets/video/about-loop.mp4'),
    @(("https://res\.cloudinary\.com/$Q" + 'Banochki2\.mp4'), '@@/assets/video/cold-hero.mp4'),
    @(("https://res\.cloudinary\.com/$Q" + 'Banochki2\.jpg'), '@@/assets/img/poster-cold.jpg'),
    @(("https://res\.cloudinary\.com/$Q" + 'howuse\.mp4'), '@@/assets/video/howuse.mp4'),
    @(("https://res\.cloudinary\.com/$Q" + 'howuse\.jpg'), '@@/assets/img/poster-howuse.jpg')
  )
  foreach($m in $map){ $t = Rx $t $m[0] $m[1] }
  # решта: бази для фото (…/image/upload/ або …/upload/<перетворення>/) → локальна папка
  $t = Rx $t ("https://res\.cloudinary\.com/w9airxdm/image/upload/$Q/([0-9A-Za-z_.-]+\.(?:jpg|png))(?=\x27)") '@@/assets/img/$1'
  $t = Rx $t ("https://res\.cloudinary\.com/w9airxdm/image/upload/$Q/(?=\x27)") '@@/assets/img/'
  $t = Rx $t ("https://res\.cloudinary\.com/w9airxdm/image/upload/(?=\x27)") '@@/assets/img/'
  $t = Rx $t "tf   : '[^']*'" "tf   : ''"
  $t = Rx $t "main : '[^']*'" "main : ''"
  $t = Rx $t "thumb: '[^']*'" "thumb: ''"
  $t = Rx $t "\['(\d)before', '(\d)fafter'\]" "['`$1before.jpg', '`$2fafter.jpg']"
  $t = $t.Replace("'v1791229140/1_Damore.jpg'", "'time-1.jpg'").Replace("'c_crop,g_south,h_0.94,w_1.0/v1791229140/2_Lodo_Damore-7.jpg'", "'time-2.jpg'").Replace("'v1791229140/3_Lodo_Damore-19.png'", "'time-3.jpg'")

  # ---- посилання ----
  $t = Rx $t "([\x27\x22])/#rec4427122103([\x27\x22])" '$1@@/#dm-ct$2'
  $t = $t.Replace('#rec4427122103', '#dm-ct')
  foreach($p in 'catalog/cold-reconstruction','catalog/home-care','catalog/body-care','catalog/accessories','catalog/gifts','catalog','about','blog'){
    $t = Rx $t ("([\x27\x22])/" + [regex]::Escape($p) + "([\x27\x22])") ('$1@@/' + $p + '/$2')
  }
  foreach($p in 'delivery','returns','faq','offer','privacy'){ $t = Rx $t ("([\x27\x22])/$p([\x27\x22])") '$1#demo$2' }
  $t = $t.Replace("home : '/'", "home : '@@/'").Replace("{ t:'Головна', h:'/' }", "{ t:'Головна', h:'@@/' }").Replace('href="/"', 'href="@@/"')

  # ---- меню: кошик-демо, головна без index.html ----
  if ($t.Contains('dmh-wrap')){
    $t = Rx $t "cartPage : '[^']*'" "cartPage : ''"
    $t = $t.Replace("cart : '#order'", "cart : '#demo-cart'")
    $t = $t.Replace("A.pathname.replace(/^\/+/, '')", "A.pathname.replace(/^\/+/, '').replace(/index\.html`$/, '')")
  }
  return $t
}

function Block([string]$f){
  $p = Join-Path $src $f; if (-not (Test-Path $p)) { $p = Join-Path $own $f }
  if (-not (Test-Path $p)) { throw "немає блоку $f" }
  return Conv ([IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)) $f
}

$fav = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23AB3724' d='M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z'/%3E%3C/svg%3E"

function Page([string]$rel, [int]$depth, [string]$title, [string]$desc, [string[]]$blocks){
  $title = $title.Replace('{AP}', [string][char]0x2019); $desc = $desc.Replace('{AP}', [string][char]0x2019)
  $body = ($blocks | ForEach-Object { Block $_ }) -join "`n"
  $html = @"
<!doctype html>
<html lang="uk">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title</title>
<meta name="description" content="$desc">
<meta property="og:title" content="$title">
<meta property="og:description" content="$desc">
<meta property="og:type" content="website">
<link rel="icon" href="$fav">
<style>html{scroll-behavior:smooth} body{margin:0; background:#F6F2EE}</style>
</head>
<body>
$body
<script src="@@/assets/demo.js"></script>
</body>
</html>
"@
  # шрифт Onest – локальний файл замість Google Fonts; Pinyon Script лишається з Google (файлу немає)
  $html = [regex]::Replace($html, '<link rel="preconnect" href="https://fonts\.g[a-z]+\.com"[^>]*>\s*', '')
  $html = [regex]::Replace($html, '<link href="https://fonts\.googleapis\.com/css2\?[^"]*" rel="stylesheet">\s*', '')
  $fontHead = @"
<link rel="preload" href="@@/assets/fonts/Onest-VariableFont_wght.ttf" as="font" type="font/ttf" crossorigin>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Pinyon+Script&display=swap" rel="stylesheet">
<style>@font-face{font-family:'Onest'; src:url('@@/assets/fonts/Onest-VariableFont_wght.ttf') format('truetype'); font-weight:100 900; font-style:normal; font-display:swap}</style>
"@
  $html = $html.Replace('<style>html{scroll-behavior:smooth}', $fontHead + "`n" + '<style>html{scroll-behavior:smooth}')
  $left = [regex]::Matches($html, 'res\.cloudinary\.com').Count
  if ($left -gt 0) { Write-Warning "$rel : лишилось посилань на Cloudinary: $left" }
  $prefix = if ($depth -eq 0) { './' } else { ('../' * $depth) }
  $html = $html.Replace('@@/', $prefix)
  $target = Join-Path $out $rel
  New-Item -ItemType Directory -Force (Split-Path -Parent $target) | Out-Null
  [IO.File]::WriteAllText($target, $html, $utf8)
  "{0,-48} {1,7:N1} KB" -f $rel, ($html.Length / 1KB)
}

# ---- підготовка фото: обрізати зверху напис «10 of 289» на time-2 (робиться один раз) ----
$t2 = Join-Path $out 'assets\img\time-2.jpg'; $mark = Join-Path $out 'assets\img\.time-2.cropped'
if ((Test-Path $t2) -and -not (Test-Path $mark)){
  Add-Type -AssemblyName System.Drawing
  $img = [Drawing.Image]::FromFile($t2); $cut = [int]($img.Height * 0.06)
  $bmp = New-Object Drawing.Bitmap $img.Width, ($img.Height - $cut)
  $g = [Drawing.Graphics]::FromImage($bmp); $g.DrawImage($img, (New-Object Drawing.Rectangle 0,0,$bmp.Width,$bmp.Height), (New-Object Drawing.Rectangle 0,$cut,$img.Width,($img.Height - $cut)), [Drawing.GraphicsUnit]::Pixel); $g.Dispose(); $img.Dispose()
  $bmp.Save("$t2.new", [Drawing.Imaging.ImageFormat]::Jpeg); $bmp.Dispose()
  Move-Item -Force "$t2.new" $t2; New-Item -ItemType File $mark | Out-Null
}

$common = @('cursor-block.html','topbar-block.html','menu-block.html')
$tail   = @('footer-block.html')

Page 'index.html' 0 'D{AP}AMORE — професійний догляд за волоссям' 'D{AP}AMORE: набір «Холодна реконструкція» — салонний догляд за волоссям вдома. Moment for me.' ($common + @('hero-block.html','video-slider-light-block.html','before-after-block.html','categories-block.html','blog-block.html','about-teaser-block.html','benefits-block.html') + $tail)
Page 'about/index.html' 1 'Про бренд — D{AP}AMORE' 'Історія D{AP}AMORE: чому ми створили догляд, який нагадує — ти теж важлива.' ($common + @('about-1-hero-block.html','about-2-story-block.html','about-3-time-block.html','about-4-manifest-block.html') + $tail)
Page 'catalog/index.html' 1 'Каталог — D{AP}AMORE' 'Розділи продукції D{AP}AMORE.' ($common + @('catalog-page-block.html','benefits-block.html') + $tail)
Page 'catalog/cold-reconstruction/index.html' 2 'Холодна реконструкція — D{AP}AMORE' '5-етапний догляд за волоссям: шампунь, маска, кондиціонер, молочко для блиску, спрей-термозахист.' ($common + @('cold-hero-block.html','store-card-block.html','product-details-block.html','benefits-block.html') + $tail)
foreach($s in @(@('home-care','stub-home-care.html','Домашній догляд'),@('body-care','stub-body-care.html','Догляд за тілом'),@('accessories','stub-accessories.html','Аксесуари'),@('gifts','stub-gifts.html','Сертифікати та подарунки'))){
  Page ("catalog/$($s[0])/index.html") 2 ("$($s[2]) — D{AP}AMORE") 'Цей розділ з{AP}явиться скоро.' ($common + @($s[1]) + $tail)
}
Page 'blog/index.html' 1 'Блог — D{AP}AMORE' 'Про догляд, відновлення і маленькі моменти для себе.' ($common + @('blog-block.html') + $tail)
'готово'
