function exec
{
	# -NoNewWindow does not seem to work in PowerShell ISE
    Start-Process -FilePath $args[0] -ArgumentList "-File",$args[1] -WindowStyle Hidden
}

$contexte = @("rien")

# 1
$contexte += "Il y a une application qui pompe toute la bande passante !
Trouvez son nom et détruisez-la."

# 2
$contexte += "Le PC est super lent. Une application monopolise le CPU !
Trouvez le nom de cette application et détruisez-la."

# 3
$contexte += "Il y a un truc bizarre, l'activité du disque est permanente.
Une application folle s'est mise à écrire de grandes quantités de données dans un fichier.
Trouvez ce fichier et l'application responsable du problème, puis détruisez-les !"

# 4
# No evt in 2016 when IP address changes ...
# 2012 : evt from iphlpsvc, at least
$contexte += "Le PC ne peut plus se connecter à internet.
Vous devriez jeter un coup d'oeil sur la configuration IP..."

# 5
$contexte += "Le PC ne peut plus se connecter à internet.
Vous devriez jeter un coup d'oeil sur la configuration IP..."

# 6
$contexte += "On soupçonne que des pirates mexicains tentent de s'introduire
dans notre réseau. Trouvez quel compte est attaqué."

# 7
$contexte += "Les services secrets mexicains ont réussi à pénétrer notre réseau !
Regardez l'observateur d'évènements pour déterminer ce qu'ils ont modifié."

$prog_prefix = "C:\Windows\System128"
$powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$prog_list = @("explorer32.exe", "svchost32.exe", "smss32.exe", "csrss32.exe", "iexplore32.exe",
						"acrotray32.exe", "services32.exe", "spoolsv32.exe", "savscan32.exe", "ctfmon32.exe")

New-Item -Path "$prog_prefix" -ItemType "directory"

foreach ($prog in $prog_list)
{
    Copy-Item "$powershell_path" "$prog_prefix\$prog"
}

foreach ($defi in 1..4 | Sort-Object {Get-Random})
{
    $i = Get-Random -Maximum $prog_list.Length
    $prog = "$prog_prefix\$prog_list[$i]"

    switch ($defi)
    {
        1
        {
            exec "$prog" ".\net.ps1"
        }
        2
        {
            exec "$prog" ".\cpu.ps1"
        }
        3
        {
            exec "$prog" ".\diskio.ps1"
        }
        4
        {
					$ifIndex = (Get-NetAdapter -Physical | Where-Object status -eq "Up").ifIndex
					# Release DHCP; works on 2012; not on 2016 ?
					#$lan = WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object Index -eq $ifIndex
					#$lan.ReleaseDHCPLease() | out-Null
					# Configure static IP instead
					New-NetIPAddress -InterfaceIndex 14 -IPAddress "198.51.100.1" -PrefixLength 24
        }
        5
				{
					$ifIndex = (Get-NetAdapter -Physical | Where-Object status -eq "Up").ifIndex
					Set-DnsClientserveraddress -InterfaceIndex 17 -ServerAddresses ("8.8.8.8")
				}
				6
				{
					foreach ($i in 1..5)
					{
						$pass = ConvertTo-SecureString -AsPlainText "keysersoze" -force
						$c = New-Object System.Management.Automation.PSCredential("hank", $pass)
						try
						{
							Start-Process .\notepad.exe -Credential $c
						}
						catch
						{
						}

						Start-Sleep 1
					}
				}
				10
        {
            # Planificateur des tâches désactivé en mode sans échec !
            $action=New-ScheduledTaskAction -Execute "C:\Windows\System32\shutdown.exe /r /t 30"
            $trigger=New-ScheduledTaskTrigger -AtStartup
            Register-ScheduledTask -TaskName "Service Actif" -Trigger $trigger -Action $action -Description "Reboot" -User "Administrateur" –Password vitrygtr
            Restart-Computer
        }
    }

    Write-Host "Nouvel incident !" -ForegroundColor Green
    [console]::beep(500,300)

    Write-Host "----------"
    Write-Host $contexte[$defi]
    Write-Host "----------"

    Write-Host ""
    Write-Host -NoNewline "Quand le problème est réglé, appuyez sur Entrée pour passer au suivant ..."

    Read-Host

		Start-Sleep 5
}
