# Show Icons on desktop
$desktop_icons =
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    Description = "This PC"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
    Description = "Control Panel"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
    Description = "User's Files"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{645FF040-5081-101B-9F08-00AA002F954E}"
    Description = "Recycle Bin"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
    Description = "Network"
} | group Path

foreach($setting in $desktop_icons){
    $registry = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}

# Set desktop to arrange icons by type
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$desktopSettingsPath = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"

# Ensure the Bags key exists
if (-not (Test-Path $desktopSettingsPath)) {
    New-Item -Path $desktopSettingsPath -Force | Out-Null
}

# Set the desktop to arrange icons by type
Set-ItemProperty -Path $desktopSettingsPath -Name "Sort" -Value 0
Set-ItemProperty -Path $desktopSettingsPath -Name "ArrangeBy" -Value 0

# Function to refresh the desktop
$signature = @"
[DllImport("shell32.dll")]
public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
"@
Add-Type -MemberDefinition $signature -Name "WinAPI" -Namespace "Win32"

# Refresh the desktop to apply changes
[Win32.WinAPI]::SHChangeNotify(0x8000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)


#######################################################
# Set Time Zone and resync time
Write-Host "Set Time Zone"
tzutil /s "Arabian Standard Time"
w32tm /resync /nowait

# Install choco
Write-Host "Install choco..."
cd / ; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Notepad++
Write-Host "Install Notepad++..."
choco install notepadplusplus --yes

# Install librewolf
Write-Host "Install librewolf..."
choco install librewolf --yes

# Disable Windows Update permanently
Write-Host "Disable Windows Update permanently"
Stop-Service -Name wuauserv -Force
Set-Service -Name wuauserv -StartupType Disabled
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force

# Disable Windows Update permanently
Write-Host "Disable Windows Update permanently"
Stop-Service -Name wsearch -Force
Set-Service -Name wsearch -StartupType Disabled

# Hide Task View button
Write-Host "Hiding Task View button..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

# Disable Disable Realtime Monitoring
Write-Host "Disable DisableRealtimeMonitoring"
set-MpPreference -DisableRealtimeMonitoring $true
set-MpPreference -DisableIOAVProtection $true
set-MpPreference -DisableAutoExclusions $true

# Exclude Directory path
if (-not (Test-Path 'C:\Tools')) {
    New-Item -Path 'C:\Tools' -ItemType Directory
}
Add-MpPreference -ExclusionPath "C:\Tools"
