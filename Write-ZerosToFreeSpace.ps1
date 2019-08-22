<#
.SYNOPSIS
 Writes a large file full of zeroes to a volume in order to allow a storage
 appliance to reclaim unused space.

.DESCRIPTION
 Creates a file called ThinSAN.tmp on the specified volume that fills the
 volume up to leave only the percent free value (default is 5%) with zeroes.
 This allows a storage appliance that is thin provisioned to mark that drive
 space as unused and reclaim the space on the physical disks.
 
.PARAMETER Root
 The folder to create the zeroed out file in.  This can be a drive root (c:\)
 or a mounted folder (m:\mounteddisk).  This must be the root of the mounted
 volume, it cannot be an arbitrary folder within a volume.
 
.PARAMETER PercentFree
 A float representing the percentage of total volume space to leave free.  The
 default is .05 (5%)

.EXAMPLE
 PS> Write-ZeroesToFreeSpace -Root "c:\"
 
 This will create a file of all zeroes called c:\ThinSAN.tmp that will fill the
 c drive up to 95% of its capacity.
 
.EXAMPLE
 PS> Write-ZeroesToFreeSpace -Root "c:\MountPoints\Volume1" -PercentFree .1
 
 This will create a file of all zeroes called
 c:\MountPoints\Volume1\ThinSAN.tmp that will fill up the volume that is
 mounted to c:\MountPoints\Volume1 to 90% of its capacity.

.EXAMPLE
 PS> Get-WmiObject Win32_Volume -filter "drivetype=3" | Write-ZeroesToFreeSpace
 
 This will get a list of all local disks (type=3) and fill each one up to 95%
 of their capacity with zeroes.
 
.NOTES
 You must be running as a user that has permissions to write to the root of the
 volume you are running this script against. This requires elevated privileges
 using the default Windows permissions on the C drive.
#>
param(
  [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
  [ValidateNotNullOrEmpty()]
  [Alias("Name")]
  $Root,
  [Parameter(Mandatory=$false)]
  [ValidateRange(0,1)]
  $PercentFree =.05
)
process{
  #Convert the $Root value to a valid WMI filter string
  $FixedRoot = ($Root.Trim("\") -replace "\\","\\") + "\\"
  $FileName = "ThinSAN.tmp"
  $FilePath = Join-Path $Root $FileName
  
  #Check and make sure the file doesn't already exist so we don't clobber someone's data
  if( (Test-Path $FilePath) ) {
    Write-Error -Message "The file $FilePath already exists, please delete the file and try again"
  } else {
    #Get a reference to the volume so we can calculate the desired file size later
    $Volume = gwmi win32_volume -filter "name='$FixedRoot'"
    if($Volume) {
      #I have not tested for the optimum IO size ($ArraySize), 64kb is what sdelete.exe uses
      $ArraySize = 64kb
      #Calculate the amount of space to leave on the disk
      $SpaceToLeave = $Volume.Capacity * $PercentFree
      #Calculate the file size needed to leave the desired amount of space
      $FileSize = $Volume.FreeSpace - $SpacetoLeave
      #Create an array of zeroes to write to disk
      $ZeroArray = new-object byte[]($ArraySize)
      
      #Open a file stream to our file 
      $Stream = [io.File]::OpenWrite($FilePath)
      #Start a try/finally block so we don't leak file handles if any exceptions occur
      try {
        #Keep track of how much data we've written to the file
        $CurFileSize = 0
        while($CurFileSize -lt $FileSize) {
          #Write the entire zero array buffer out to the file stream
          $Stream.Write($ZeroArray,0, $ZeroArray.Length)
          #Increment our file size by the amount of data written to disk
          $CurFileSize += $ZeroArray.Length
        }
      } finally {
        #always close our file stream, even if an exception occurred
        if($Stream) {
          $Stream.Close()
        }
        #always delete the file if we created it, even if an exception occurred
        if( (Test-Path $FilePath) ) {
          del $FilePath
        }
      }
    } else {
      Write-Error "Unable to locate a volume mounted at $Root"
    }
  }
}
# SIG # Begin signature block
# MIIFdQYJKoZIhvcNAQcCoIIFZjCCBWICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXhfB7bWakDX1xMQ1BseuM8b5
# KyOgggMVMIIDETCCAfmgAwIBAgIQPNCPdS05HoBLUkkvA/hnHTANBgkqhkiG9w0B
# AQsFADAVMRMwEQYDVQQDDApFR0NHM1dCRkZWMB4XDTE5MDgwNzE3NTcxNVoXDTIw
# MDgwNzE4MTcxNVowFTETMBEGA1UEAwwKRUdDRzNXQkZGVjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBANZc+wZW964fPVQVoMpudnRmCYCaIukMRoqRfBH7
# X5/yAws00Y9ChWe7CvVA2spWx1XsfmJDSlwwT/TrcO8wyqv5W8gPpn48nBot+Es0
# iB5WaTe02EUYT1lEZoac6Fp/MB6/aQ2uGUASIsT/pKzMpkIajBhqw13tj2LHn3/L
# AltES63RTWzuQmNr8vRqKjOtZsqHxHNbXhY8UDTtQn5KJEvY3kwPBs2b1I/0yB0l
# c8Ic6mSGDN7GaeVkFAZDODJz1UpfBxlByG8ebYQJ85HDIzsi45SMWdP7wSzruGnD
# yUN1FTE2mrFn+dALOYWQXhYBfDHKJNaEK1l148idK0IBed0CAwEAAaNdMFswDgYD
# VR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBUGA1UdEQQOMAyCCkVH
# Q0czV0JGRlYwHQYDVR0OBBYEFNV3nfSmo3qNmkVBV8VQ9AXcpf63MA0GCSqGSIb3
# DQEBCwUAA4IBAQC9j8QgMmapXwXQn3QfVkuB5METJgeZJgIylUoU27ZHIqjdw8FT
# Kat5BvG5bNf8CP1LuKcmZam1PCexjTPRc1mZOMVmJpfn4AaTPF6MecLWo6trNHxZ
# +EgDgekrvn6MVzSnv3L/qbUTJkz0uLis4z0ME921NZFmAhkfCMBmRNfV5M0Lr538
# C4zg/kc/davsV/EP3ghDjG0Bylw/DDN/G/RRJt+TBfaPnxVo8gZbJZyHT/1AxNMU
# R76yHzTBUnVf0IpTVgjIivw1kQT+HYOiXcxbh/0vtCBb2gxrVp+jrJ97jDznseoY
# b15/QHyeSAClc0+vDd03OMJCdDp4u/I2WPE4MYIByjCCAcYCAQEwKTAVMRMwEQYD
# VQQDDApFR0NHM1dCRkZWAhA80I91LTkegEtSSS8D+GcdMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBSsB3pqpD0elL58Jt7Fi4lK2CsXzjANBgkqhkiG9w0BAQEFAASCAQATFqKecFg2
# 4PKG2ypvuON1uJxXuhZ6kTzEjKo9r7W0jTpHFIWZZJXIHgr2dA4EBlDCF6N50Wy1
# DF8DDmll9Dnr9FDkWvUCdzryqFJ29cMsHKy06deYhKXzFPxgntLcdVUwEFevAvQs
# kYi8/rpnT33VKq/NHY5dzO1qhY+uxk7vxmYh3Vcta95EeODPOJi7CXIwXy9Vghyy
# 2lVOcRyjhRCcjB539LJtGy+AZZ+e1tUhcyms1hfMDP4dTUbH9//At4j0Am4pFyHR
# Tci/a8CeXJX8F2G0m9MiP16B0OyYGEI6QDzCP2TDQl+wDj/UTJCoRH5LXzTx9pkZ
# 0wqa+YKi6H+t
# SIG # End signature block
