$_installPath = "$($env:LOCALAPPDATA)\Programs\On The Roadside"


Write-Host "ON THE ROADSIDE" -BackgroundColor Gray -ForegroundColor Yellow

if(Test-Path $_installPath) {
    Write-Host "Game already installed. Do you want to reinstall ON THE ROADSIDE? (y/n): " -NoNewline
} else {
    Write-Host "Do you want to install ON THE ROADSIDE? (y/n): " -NoNewline
}

while($true) {
    $input = Read-Host
    if($input -eq "y") {
        break
    } elseif($input -eq "n") {
        exit
    } else {
        Write-Host "Sorry? (y/n): " -NoNewline
    }
}



### Download current LOVE framework executable ###

# By default PowerShell supports only SSL3 and TLS1.0, add TLS1.1 and TLS1.2 support.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'

# Download current version of the LOVE framework
$request = Invoke-WebRequest "https://love2d.org/"
$match = (Select-String -InputObject $request.Content -Pattern "https://bitbucket\.org/rude/love/downloads/love-(.*)-win64\.zip").Matches[0]
$dlUri = $match.Groups[0].Value
$_loveVersion = $match.Groups[1].Value

$dlBaseName = "love-$_loveVersion-win64"
$dlFileName = "$dlBaseName.zip"
Invoke-WebRequest $dlUri -OutFile "$($ENV:TEMP)\$dlFileName"

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$($ENV:TEMP)\$dlFileName", "$($ENV:TEMP)\$dlBaseName")
$subdir = Get-ChildItem "$($ENV:TEMP)\$dlBaseName"
New-Item $_installPath -ItemType Directory -ErrorAction SilentlyContinue
Get-ChildItem $subdir.FullName -Recurse | % { Move-Item $_.FullName -Destination "$_installPath\$($_.FullName.Replace($subdir.FullName+"\", ''))" -Force }

Remove-Item -Recurse "$($ENV:TEMP)\$dlBaseName" -ErrorAction SilentlyContinue
Remove-Item -Recurse "$($ENV:TEMP)\$dlFileName" -ErrorAction SilentlyContinue


# Extract only love.exe (using Streams)
#Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
#$zipArchive = New-Object System.IO.Compression.ZipArchive($loveBinary.RawContentStream)
#$zipEntry = $zipArchive.Entries | ? { $_.Name -eq "love.exe" }
# Save love.exe (streto disk
#$sw = [System.IO.FileStream]::new($tempLovePath, [System.IO.FileMode]::Create)
#$stream = $zipEntry.Open()
#$stream.CopyTo($sw)
#$stream.Close()
#$sw.Close()

# Compress Src
Remove-Item "$_installPath\On The Roadside.love" -ErrorAction SilentlyContinue
[System.IO.Compression.ZipFile]::CreateFromDirectory((get-location), "$_installPath\On The Roadside.love")

# Append
$otr = [System.IO.FileStream]::new("$_installPath\On The Roadside.exe", [System.IO.FileMode]::Create)
$lve = [System.IO.FileStream]::new("$_installPath\love.exe", [System.IO.FileMode]::Open)
$gme = [System.IO.FileStream]::new("$_installPath\On The Roadside.love", [System.IO.FileMode]::Open)

$lve.CopyTo($otr)
$gme.CopyTo($otr)
 
$otr.Close()
$lve.Close()
$gme.Close()

# Create Desktop Shortcut
$wshshell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
$lnk = $wshshell.CreateShortcut($desktop+"\On The Roadside.lnk")
$lnk.TargetPath = "$_installPath\On The Roadside.exe"
$lnk.Save() 

pause