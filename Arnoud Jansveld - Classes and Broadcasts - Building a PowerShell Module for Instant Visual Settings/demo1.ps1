# Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa

$typeDefinition = '
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto, EntryPoint = "SystemParametersInfo")]
public static extern bool SetSystemParametersInfoBool(
    int uiAction, int uiParam, bool lpvParam, int fuWinIni);
'
Add-Type -Name 'User' -Namespace 'Win32' -Language CSharp -MemberDefinition $typeDefinition

# Write the new setting to the user profile, and broadcasts the WM_SETTINGCHANGE message
$winIni = 3

$mouseTrails = 0x005D

# Turn mouse trails on
[Win32.User]::SetSystemParametersInfoBool($mouseTrails, 10, 0, $winIni)

# Turn them back off
[Win32.User]::SetSystemParametersInfoBool($mouseTrails, 0, 0, $winIni)



$dragFullWindows = 0x0025

# Turn full window dragging on
[Win32.User]::SetSystemParametersInfoBool($dragFullWindows, $true, 0, $winIni)

# Turn it off
[Win32.User]::SetSystemParametersInfoBool($dragFullWindows, $false, 0, $winIni)
