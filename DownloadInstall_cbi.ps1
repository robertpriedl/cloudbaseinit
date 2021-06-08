# Downloads the Cloudbase-init installer x64 and downloads the config files for cloudbase-init with adapted ovf settings
# to use in a vSphere Environment with VMware vRealize Automation Cloud Templates (v8.x)
# Author: Robert Priedl
# Date: 20210608
# The code is working for me - use it on your own risk!

function DownloadFilesFromRepo {
# function for downloading Github Repo with Cloudbase-init Config files
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

# Call Function to download github repo with config files
DownloadFilesFromRepo -Owner robertpriedl -Repository cloudbaseinit -DestinationPath "$env:Temp"
# Download Cloudbase-init Setup
Invoke-RestMethod -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi" -Outfile "$env:temp\CloudbaseInitSetup_Stable_x64.msi"
# Install cloudbase-init
msiexec /i "$env:temp\CloudbaseInitSetup_Stable_x64.msi" /qn /l*v "C:\Windows\Temp\CloudInit.log" LOGGINGSERIALPORTNAME=COM1
# wait for ending msiexec
start-sleep -Seconds 2
While ((get-process -Name msiexec).count -gt 1){
    Start-Sleep -Seconds 5
}
# copy temporary downloaded config files
copy-item -path "$env:temp\cloudbase-init.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
copy-item -path "$env:temp\cloudbase-init-unattend.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
copy-item -path "$env:temp\unattend.xml" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\unattend.xml"
# switch to cloudbase folder
set-location "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\"
# execute sysprep
Invoke-Expression -command "c:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /unattend:Unattend.xml"
