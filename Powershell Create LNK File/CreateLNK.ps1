$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut(“C:\Users\charl\OneDrive\Desktop\fancybear.lnk”)

# Set properties for the shortcut
$Shortcut.TargetPath = “C:\Windows\System32\cmd.exe”
$Shortcut.WorkingDirectory = “C:\Windows\System32\”
$Shortcut.Description = “This is a shortcut that we need for our business.”
$Shortcut.Arguments = '/c powershell -ep bypass'
$Shortcut.IconLocation = ‘C:\Windows\System32\msi.dll’
$Shortcut.WindowStyle = 1 # 1 — Normal, 3 — Maximized, 7 — Minimized
$Shortcut.Save()
