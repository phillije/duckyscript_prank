# lockdown-demo.ps1
# Demo: maximise console, remove Close (X) button, ignore Ctrl+C/Alt+F4,
# and require a secret code to exit.
# Run with:
#   powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0lockdown-demo.ps1"

# ----- Helper: define Win32 calls in C# -----
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class Win32Console {
    public delegate bool ConsoleCtrlDelegate(uint ctrlType);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);

    [DllImport("user32.dll")]
    public static extern bool RemoveMenu(IntPtr hMenu, uint uPosition, uint uFlags);

    // For optional restoring: call GetSystemMenu(hWnd, true) to revert the menu.
    [DllImport("kernel32.dll")]
    public static extern bool SetConsoleCtrlHandler(ConsoleCtrlDelegate HandlerRoutine, bool Add);
}
'@

# ----- Constants -----
$SW_SHOWMAXIMIZED = 3
$SC_CLOSE = 0xF060
$MF_BYCOMMAND = 0x00000000

# ----- Get console handle and maximise -----
$hwnd = [Win32Console]::GetConsoleWindow()
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Warning "Couldn't get console window handle. Run from the standalone console (not ISE)."
} else {
    [Win32Console]::ShowWindow($hwnd, $SW_SHOWMAXIMIZED) | Out-Null
}

# ----- Remove the close (X) button from system menu -----
try {
    $hMenu = [Win32Console]::GetSystemMenu($hwnd, $false)
    if ($hMenu -ne [IntPtr]::Zero) {
        [Win32Console]::RemoveMenu($hMenu, [uint32]$SC_CLOSE, [uint32]$MF_BYCOMMAND) | Out-Null
    }
} catch {
    Write-Warning "Could not remove close menu: $_"
}

# ----- Borderless fullscreen (cover taskbar) -----
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class Win32FS {
    public const int GWL_STYLE = -16;
    public const long WS_OVERLAPPEDWINDOW = 0x00CF0000;
    public const long WS_VISIBLE = 0x10000000;

    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);

    public const uint SWP_SHOWWINDOW = 0x0040;
    public const uint SWP_FRAMECHANGED = 0x0020;

    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
    [DllImport("user32.dll")] public static extern IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);
    [DllImport("user32.dll")] public static extern IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter,
        int X, int Y, int cx, int cy, uint uFlags);
}
'@

if ($hwnd -ne [IntPtr]::Zero) {
    # Remove standard window chrome (caption, borders, etc.)
    $style = [Win32FS]::GetWindowLongPtr($hwnd, [Win32FS]::GWL_STYLE)
    $newStyle = [IntPtr]([uint64]$style -band -bnot [uint64][Win32FS]::WS_OVERLAPPEDWINDOW -bor [uint64][Win32FS]::WS_VISIBLE)
    [Win32FS]::SetWindowLongPtr($hwnd, [Win32FS]::GWL_STYLE, $newStyle) | Out-Null

    # Get primary screen size
    $SM_CXSCREEN = 0
    $SM_CYSCREEN = 1
    $w = [Win32FS]::GetSystemMetrics($SM_CXSCREEN)
    $h = [Win32FS]::GetSystemMetrics($SM_CYSCREEN)

    # Resize and raise above taskbar (topmost)
    [Win32FS]::SetWindowPos($hwnd, [Win32FS]::HWND_TOPMOST, 0, 0, $w, $h,
        [Win32FS]::SWP_SHOWWINDOW -bor [Win32FS]::SWP_FRAMECHANGED) | Out-Null
}

# ----- Prevent Ctrl+C / Close events by registering a no-op handler -----
# Return true to indicate the event was handled (so Windows won't terminate)
$handler = [Win32Console+ConsoleCtrlDelegate]{
    param([uint32] $ctrlType)
    # Ctrl types: 0 = CTRL_C_EVENT, 2 = CTRL_CLOSE_EVENT, 5 = CTRL_LOGOFF_EVENT, 6 = CTRL_SHUTDOWN_EVENT
    return $true
}
[Win32Console]::SetConsoleCtrlHandler($handler, $true) | Out-Null

# ----- Tidy console appearance (avoid scrollbars) -----
try {
    $raw = $host.UI.RawUI
    $raw.BufferSize = $raw.WindowSize   # match buffer to window to avoid scrollbars
} catch {
    # Ignore if environment doesn't allow changes (e.g. Windows Terminal)
}

# ----- UI: fake lockdown message -----
Clear-Host
Write-Host "============================================="
Write-Host "   LOCKDOWN DEMO - kiosk-like console active   "
Write-Host "=============================================`n"
Write-Host "This console is maximised, the close button is hidden,"
Write-Host "and Ctrl+C / standard close events are being intercepted."
Write-Host ""
Write-Host "To exit cleanly, type the secret code when prompted."
Write-Host "If this becomes unresponsive, use Task Manager to end the process."
Write-Host ""

# ----- Main loop: simple interactive demo -----
$secret = "letmeout"   # change this if you want a different secret
$attempts = 0
while ($true) {
    $attempts += 1
    $input = Read-Host "Type the secret code to unlock (attempt $attempts)"
    if ($input -eq $secret) {
        Write-Host "`nSecret accepted - restoring normal console and exiting..."
        break
    } else {
        Write-Host "Wrong code. Nice try! (Tip: this is only a demo.)`n"
    }
    Start-Sleep -Seconds 1
}

# ----- Cleanup: restore system menu (revert) and unregister handler -----
try {
    # Revert system menu to original by requesting GetSystemMenu with bRevert = true
    [Win32Console]::GetSystemMenu($hwnd, $true) | Out-Null
} catch { }

try {
    [Win32Console]::SetConsoleCtrlHandler($handler, $false) | Out-Null
} catch { }

# Optional: restore normal window (not required)
$SW_RESTORE = 9
try {
    [Win32Console]::ShowWindow($hwnd, $SW_RESTORE) | Out-Null
} catch { }

Write-Host "Exited cleanly. Have a nice day!"
Exit 0
