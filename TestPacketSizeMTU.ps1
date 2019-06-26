$UpperBoundPacketSize = Read-Host -Prompt "Input packet size to test`t"
$IpToPing = Read-Host -Prompt "Input IP address to test`t"
do {
    Write-Output "Testing packet size $UpperBoundPacketSize"
    $PingOut = ping $IpToPing -n 1 -l $UpperBoundPacketSize -f
    Write-Host "Executing Command:  "$PingOut
    $UpperBoundPacketSize -= 1
} while ($PingOut[2] -like "*fragmented*")
 
$UpperBoundPacketSize += 1
$Mtu = $UpperBoundPacketSize + 28
 
New-Object -TypeName PSObject -Property @{
    MTU = $MTU
}

Clear-Variable UpperBoundPacketSize
Clear-Variable IpToPing