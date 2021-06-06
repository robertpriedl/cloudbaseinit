Invoke-WebRequest -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi" -Outfile "$env:temp\CloudbaseInitSetup_Sable_x64.msi"
Invoke-WebRequest -Uri "https://github.com/robertpriedl/cloudbaseinit/blob/main/cloudbase-init-unattend.conf" -Outfile "$env:temp\cloudbase-init-unattend.conf"
Invoke-WebRequest -Uri "https://github.com/robertpriedl/cloudbaseinit/blob/main/cloudbase-init.conf" -Outfile "$env:temp\cloudbase-init.conf"
Invoke-WebRequest -Uri "https://github.com/robertpriedl/cloudbaseinit/blob/main/Unattend.xml" -Outfile "$env:temp\Unattend.xml"

msiexec /i "%~dp01CloudbaseInitSetup__0__9__11__x64.msi" /qn /l*v "C:\Windows\Temp\CloudInit.log" LOGGINGSERIALPORTNAME=COM1
copy-item -path "$env:temp\cloudbase-init.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
copy-item -path "$env:temp\cloudbase-init-unattend.conf" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
copy-item -path "$env:temp\unattend.xml" -destination "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\unattend.xml"
set-location "$env:programfiles\Cloudbase Solutions\Cloudbase-Init\conf\"

"c:\Windows\System32\Sysprep\Sysprep.exe" /generalize /oobe /shutdown /unattend:Unattend.xml
# msiexec /I "$env:temp\CloudbaseInitSetup_Sable_x64.msi"
