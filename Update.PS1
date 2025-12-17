param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Windows", "Linux")]
    [string]$OS = "Linux",

    [Parameter(Mandatory = $false)]
    [bool]$Clean = $false,

    [Parameter(Mandatory = $false)]
    [bool]$Staging = $false
)

$FolderDependencies = Join-Path '.' 'dependencies'

if ($Clean -and (Test-Path $FolderDependencies)) {
    Remove-Item -Path $FolderDependencies -Recurse -Force
}

New-Item -Name $FolderDependencies -ItemType Directory -Force

$FolderServer = Join-Path $FolderDependencies 'server' $OS

if ($Clean -and (Test-Path $FolderServer)) {
    Remove-Item -Path $FolderServer -Recurse -Force
}

New-Item -Name $FolderServer -ItemType Directory -Force

$FolderTools = Join-Path '.' 'tools'

if ($Clean -and (Test-Path $FolderTools)) {
    Remove-Item -Path $FolderTools -Recurse -Force
}

New-Item -Name $FolderTools -ItemType Directory -Force

$FolderDepotDownloader = Join-Path $FolderTools 'DepotDownloader'

New-Item -Name $FolderDepotDownloader -ItemType Directory -Force

$DepotDownloader = Join-Path $FolderDepotDownloader 'DepotDownloader.dll'

if ($Clean -or -not (Test-Path $DepotDownloader)) {
    $LinkDepotDownloader = 'https://github.com/SteamRE/DepotDownloader/releases/latest/download/DepotDownloader-framework.zip'

    $ArchiveDepotDownloader = Join-Path $FolderDepotDownloader 'DepotDownloader.zip'

    Invoke-WebRequest $LinkDepotDownloader -OutFile $ArchiveDepotDownloader
    Expand-Archive -Path $ArchiveDepotDownloader -DestinationPath $FolderDepotDownloader -Force
    Remove-Item -Path $ArchiveDepotDownloader -Force
}

Start-Process -FilePath 'dotnet' -ArgumentList @(
    $DepotDownloader
    '-app 258550'
    "-os $($OS.ToLower())"
    $Staging ? '-branch staging' : ''
    "-dir $FolderServer"
    '-filelist RustDependencies.txt'
    '-validate'
) -NoNewWindow -Wait

switch ($OS) {
    'Windows' {
        if ($Staging) {
            $LinkOxide = 'https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust.zip'
        }
        else {
            $LinkOxide = 'https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip'
        }
    }

    'Linux' {
        if ($Staging) {
            $LinkOxide = 'https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip'
        }
        else {
            $LinkOxide = 'https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust-linux.zip'
        }
    }

    default {
        throw 'Unable to determine OS'
    }
}

$ArchiveOxide = Join-Path $FolderServer 'Oxide.zip'

Invoke-WebRequest $LinkOxide -OutFile $ArchiveOxide
Expand-Archive -Path $ArchiveOxide -DestinationPath $FolderServer -Force
Remove-Item -Path $ArchiveOxide -Force