$url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.5.0-amd64-netinst.iso"

$progressPreference = 'silentlyContinue'

while (1) {
    Invoke-WebRequest -uri $url -UseBasicParsing

    Start-Sleep 1
}

$progressPreference = 'Continue'
