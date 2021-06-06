Invoke-WebRequest -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi" -Outfile "$env:temp\CloudbaseInitSetup_Sable_x64.msi"
msiexec /I "$env:temp\CloudbaseInitSetup_Sable_x64.msi"
