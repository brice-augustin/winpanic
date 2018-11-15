$i = 0
while (1)
{
    $a *= 2
    $a /= 2

    $i++
	# Powerfull PC with 8 CPUs, make sure it takes a few seconds to complete
    if ($i -eq 10000000)
    {
        $i = 0
        Start-Sleep 1
    }
}
