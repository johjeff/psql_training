Function Check-PowerCLIUpdate {
    #Based on great module by Jeff Hicks here: http://jdhitsolutions.com/blog/powershell/5441/check-for-module-updates/
    [cmdletbinding()]
    Param()
 
    # Getting installed modules
    $modules = Get-Module -ListAvailable VMware* | Sort Version -Descending | Select-object -Unique
 
    #Filter to modules from the PSGallery
    $gallery = $modules.where({$_.repositorysourcelocation})
 
    # Comparing to online versions
    $AllUpdatedModules = @()
    foreach ($module in $gallery) {
 
         #find the current version in the gallery
         Try {
            $online = Find-Module -Name $module.name -Repository PSGallery -ErrorAction Stop
         }
         Catch {
            Write-Warning "Module $($module.name) was not found in the PSGallery and therefore not checked for an update"
         }
 
         #compare versions
         if ($online.version -gt $module.version) {
            $AllUpdatedModules += new-object PSObject -Property @{
                Name = $module.name
                InstalledVersion = $module.version
                OnlineVersion = $online.version
                Update = $True
                Path = $module.modulebase
             } 
         }
    }
    $AllUpdatedModules | Format-Table
    #Check completed
 
}