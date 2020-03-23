#Script to download and install software onto a golden image with Azure Image Builder


#Create temp folder
New-Item -Path 'C:\INSTALL' -ItemType Directory -Force | Out-Null


#Install VSCode
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\INSTALL\VScode.exe'
Invoke-Expression -Command 'c:\INSTALL\VScode.exe /verysilent'

#Start sleep
Start-Sleep -Seconds 10

#InstallNotepadplusplus
Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\INSTALL\notepadplusplus.exe'
Invoke-Expression -Command 'c:\INSTALL\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\INSTALL\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\INSTALL\fslogix.zip' -DestinationPath 'C:\INSTALL\fslogix\'  -Force
Invoke-Expression -Command 'C:\INSTALL\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 10

#InstallTeamsMachinemode
#New-Item -Path 'HKLM:\SOFTWARE\Citrix\PortICA' -Force | Out-Null
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64' -OutFile 'c:\INSTALL\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\INSTALL\Teams.msi /quiet /l*v C:\INSTALL\teamsinstall.log ALLUSER=1'
Start-Sleep -Seconds 30
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32 -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
