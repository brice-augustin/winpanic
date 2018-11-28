function exec
{
  # -NoNewWindow does not seem to work in PowerShell ISE
  Start-Process -FilePath $args[0] -ArgumentList "-File",$args[1] -WindowStyle Hidden
}

$contexte = @("rien")

# 1
$contexte += "Il y a une application qui pompe toute la bande passante !
Trouvez son nom et d�truisez-la."

# 2
$contexte += "Le PC est super lent. Une application monopolise le CPU !
Trouvez le nom de cette application et d�truisez-la."

# 3
$contexte += "Il y a un truc bizarre, l'activit� du disque est permanente.
Une application folle s'est mise � �crire de grandes quantit�s de donn�es dans un fichier.
Trouvez ce fichier et l'application responsable du probl�me, puis d�truisez-les !"

# 4
# No evt in 2016 when IP address changes ...
# 2012 : evt from iphlpsvc, at least
$contexte += "Le PC ne peut plus se connecter �internet.
Vous devriez jeter un coup d'oeil sur la configuration IP..."

# 5
$contexte += "Le PC ne peut plus se connecter �internet.
Vous devriez jeter un coup d'oeil sur la configuration IP..."

# 6
$contexte += "On soup�onne que des pirates mexicains tentent de s'introduire
dans notre r�seau. Trouvez quel compte est attaqu�."

# 7
$contexte += "Les services secrets mexicains ont r�ussi � p�n�trer notre r�seau !
Regardez l'observateur d'�v�nements pour d�terminer ce qu'ils ont modifi�."

$prog_prefix = "C:\Windows\System128"
$powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$prog_list = @("explorer32.exe", "svchost32.exe", "smss32.exe", "csrss32.exe", "iexplore32.exe",
            "acrotray32.exe", "services32.exe", "spoolsv32.exe", "savscan32.exe", "ctfmon32.exe")

if (! (Test-Path $prog_prefix))
{
  New-Item -Path "$prog_prefix" -ItemType "directory"
}

foreach ($prog in $prog_list)
{
  Copy-Item "$powershell_path" "$prog_prefix\$prog"
}

$liste_defis = 1..5 + "7"

$incident_count = 0

foreach ($defi in $liste_defis | Sort-Object {Get-Random})
{
  $i = Get-Random -Maximum $prog_list.Length
  $prog = $prog_prefix + "\" + $prog_list[$i]

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
      New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress "198.51.100.1" -PrefixLength 24 | Out-Null
    }
    5
    {
      $ifIndex = (Get-NetAdapter -Physical | Where-Object status -eq "Up").ifIndex
      Set-DnsClientserveraddress -InterfaceIndex $ifIndex -ServerAddresses ("8.8.8.8")
    }
    6
    {
      # Ev�nement pas audit� par d�faut sous Windows 10
      # Strat�gies de s�curit� locale > Auditer les �v�nements de connexion (R�ussite, �chec)
      foreach ($i in 1..5)
      {
        $pass = ConvertTo-SecureString -AsPlainText "etudiant" -force
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
    7
    {
      # Windows 10 : popup saying the firewall was disabled
      # Disable security maintenance messages ?
      Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    }
    10
    {
      # Planificateur des t�ches d�sactiv� en mode sans �chec !
      $action=New-ScheduledTaskAction -Execute "C:\Windows\System32\shutdown.exe /r /t 30"
      $trigger=New-ScheduledTaskTrigger -AtStartup
      Register-ScheduledTask -TaskName "Service Actif" -Trigger $trigger -Action $action -Description "Reboot" -User "Administrateur" -Password vitrygtr
      Restart-Computer
    }
  }

  $incident_count++

  $msg = "Nouvel incident ! (Ticket #" + $incident_count + ")"

  Write-Host $msg -ForegroundColor Green
  [console]::beep(500,300)

  Write-Host "----------"
  Write-Host $contexte[$defi]
  Write-Host "----------"

  Write-Host ""
  Write-Host -NoNewline "Quand le probl�me est r�gl�, appuyez sur Entr�e pour passer au suivant ..."

  Read-Host

  Write-Host "Attente du prochain incident ..."
  Start-Sleep 5
}

Write-Host "Vous avez r�solu tous les incidents !" -ForegroundColor Yellow
