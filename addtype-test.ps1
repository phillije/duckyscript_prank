# addtype-test.ps1
# Minimal test to confirm Add-Type here-string parses correctly.
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class Win32Test {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
}
'@

$hwnd = [Win32Test]::GetConsoleWindow()
Write-Host "Add-Type compiled. HWND: $hwnd"
