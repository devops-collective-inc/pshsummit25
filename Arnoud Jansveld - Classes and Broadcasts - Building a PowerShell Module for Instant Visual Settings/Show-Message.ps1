<#
.SYNOPSIS
    Shows WM_SETTINGCHANGE broadcast messages
.DESCRIPTION
    Used in the development of the VisualEffects module
.NOTES
    To stop the script, just close the PowerShell window
#>

$code = @'
using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class SettingsChangedHandlerForm:Form
{
    private static int WM_SETTINGCHANGE = 0x1A;

    public class SettingChangedArgs : EventArgs
    {
        public IntPtr wParam {get; set;}
        public string msg {get; set;}
    }

    public event EventHandler<SettingChangedArgs> SettingChanged;

    protected override void WndProc(ref System.Windows.Forms.Message msg)
    {
        if (msg.Msg == WM_SETTINGCHANGE){
            var text = Marshal.PtrToStringAuto(msg.LParam);
            var args = new SettingChangedArgs {wParam = msg.WParam, msg = text};
            SettingChanged.Invoke(this, args);
        }
        base.WndProc(ref msg);
    }

    public SettingsChangedHandlerForm(EventHandler<SettingChangedArgs> SettingChanged)
    {
        this.Visible = false;
        this.WindowState = FormWindowState.Minimized;
        this.SettingChanged = SettingChanged;
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        this.Activate();
    }
}
'@
$referencedAssemblies = @('System.Windows.Forms')
if ($PSEdition -eq 'Core') {
    $referencedAssemblies += 'System.ComponentModel.Primitives', 'System.Windows.Forms.Primitives'
}
Add-Type -TypeDefinition $code -ReferencedAssemblies $referencedAssemblies

$settingChangedEventHandler = {
    param($EventSender, $SettingChanged)
    '[{0}]  WM_SETTINGCHANGE  W:0x{1:x4}  L:{2}' -f (Get-Date), $SettingChanged.wParam, $SettingChanged.msg | Out-Host
}
$form = [SettingsChangedHandlerForm]::new($settingChangedEventHandler)

Write-Host -ForegroundColor Green 'Listening for messages...'
# note this will block execution
[System.Windows.Forms.Application]::Run($form)
