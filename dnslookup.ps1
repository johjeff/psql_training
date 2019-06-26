# Script found at the following site:
# http://tompaps.blogspot.com/2015/04/verify-forward-and-reverse-dns-records.html
# Usage:  "fqdn1","fqdn2","fqdn3" | .\dnslookup.ps1 | ft -auto

$hostlist = @($input)  
  
# running through the list of hosts  
$hostlist | %{  
     $obj = "" | Select ComputerName,Ping,IPNumber,ForwardLookup,ReverseLookup,Result  
     $obj.ComputerName = $_  
  
     # ping each host  
     if(Test-Connection $_ -quiet){  
          $obj.Ping = "OK"  
    $obj.Result = "OK"  
     }  
     else{  
          $obj.Ping = "Error"  
    $obj.Result = "Error"  
     }  
       
     # lookup IP addresses of the given host  
     [array]$IPAddresses = [System.Net.Dns]::GetHostAddresses($obj.ComputerName) | ?{$_.AddressFamily -eq "InterNetwork"} | %{$_.IPAddressToString}  
  
     # caputer count of IPs  
     $obj.IPNumber = ($IPAddresses | measure).count  
       
     # if there were IPs returned from DNS, go through each IP  
  if($IPAddresses){  
    $obj.ForwardLookup = "OK"  
  
       $IPAddresses | %{  
            $tmpreverse = $null  
                 
               # perform reverse lookup on the given IP  
            $tmpreverse = [System.Net.Dns]::GetHostByAddress($_).HostName  
            if($tmpreverse){  
                 
                    # if the returned host name is the same as the name being processed from the input, the result is OK  
                 if($tmpreverse -ieq $obj.ComputerName){  
                      $obj.ReverseLookup += "$_ : OK `n"  
                 }  
                 else{  
                      $obj.ReverseLookup += "$_ different hostname: $tmpreverse `n"  
                      $obj.Result = "Error"  
                 }  
            }  
            else{  
                 $obj.ReverseLookup = "No host found"  
                 $obj.Result = "Error"  
            }  
    }  
     }  
     else{  
          $obj.ForwardLookup = "No IP found"  
          $obj.Result = "Error"  
     }  
       
     # return the output object  
     $obj  
}