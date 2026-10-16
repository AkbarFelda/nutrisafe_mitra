param([string]$Source = "assets/images/logo.png")

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function Write-SquareIcon([string]$InputPath, [string]$OutputPath, [int]$Size) {
    $sourceImage = [System.Drawing.Image]::FromFile((Resolve-Path $InputPath))
    try {
        $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.Clear([System.Drawing.Color]::White)
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $padding = [Math]::Max(1, [int]($Size * 0.06))
                $available = $Size - (2 * $padding)
                $scale = [Math]::Min($available / $sourceImage.Width, $available / $sourceImage.Height)
                $width = [int]($sourceImage.Width * $scale)
                $height = [int]($sourceImage.Height * $scale)
                $x = [int](($Size - $width) / 2)
                $y = [int](($Size - $height) / 2)
                $graphics.DrawImage($sourceImage, $x, $y, $width, $height)
            } finally {
                $graphics.Dispose()
            }
            $parent = Split-Path $OutputPath -Parent
            if ($parent -and !(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
            $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $bitmap.Dispose()
        }
    } finally {
        $sourceImage.Dispose()
    }
}

$androidIcons = @{
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
}
$webIcons = @{
    "web/favicon.png" = 32
    "web/icons/Icon-192.png" = 192
    "web/icons/Icon-maskable-192.png" = 192
    "web/icons/Icon-512.png" = 512
    "web/icons/Icon-maskable-512.png" = 512
}
$iosIcons = @{
    "Icon-App-20x20@1x.png" = 20; "Icon-App-20x20@2x.png" = 40; "Icon-App-20x20@3x.png" = 60
    "Icon-App-29x29@1x.png" = 29; "Icon-App-29x29@2x.png" = 58; "Icon-App-29x29@3x.png" = 87
    "Icon-App-40x40@1x.png" = 40; "Icon-App-40x40@2x.png" = 80; "Icon-App-40x40@3x.png" = 120
    "Icon-App-60x60@2x.png" = 120; "Icon-App-60x60@3x.png" = 180
    "Icon-App-76x76@1x.png" = 76; "Icon-App-76x76@2x.png" = 152
    "Icon-App-83.5x83.5@2x.png" = 167; "Icon-App-1024x1024@1x.png" = 1024
}

foreach ($entry in $androidIcons.GetEnumerator()) { Write-SquareIcon $Source $entry.Key $entry.Value }
foreach ($entry in $webIcons.GetEnumerator()) { Write-SquareIcon $Source $entry.Key $entry.Value }
foreach ($entry in $iosIcons.GetEnumerator()) {
    Write-SquareIcon $Source (Join-Path "ios/Runner/Assets.xcassets/AppIcon.appiconset" $entry.Key) $entry.Value
}

Write-Output "App icons generated from $Source"
