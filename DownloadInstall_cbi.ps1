function DownloadFilesFromRepo {
Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}
DownloadFilesFromRepo -Owner robertpriedl -Repository cloudbaseinit -DestinationPath "$env:Temp"

Invoke-RestMethod -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi" -Outfile "$env:temp\CloudbaseInitSetup_Stable_x64.msi"

msiexec /i "$env:temp\CloudbaseInitSetup_Stable_x64.msi" /qn /l*v "C:\Windows\Temp\CloudInit.log" LOGGINGSERIALPORTNAME=COM1
copy-item -path "$env:temp\cloudbase-init.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
copy-item -path "$env:temp\cloudbase-init-unattend.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
copy-item -path "$env:temp\unattend.xml" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\unattend.xml"
set-location "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\"

Invoke-Expression -command "c:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /unattend:Unattend.xml"
# msiexec /I "$env:temp\CloudbaseInitSetup_Sable_x64.msi"
