Install:
Install-Module -Name PackagedAppLauncher

Usage:
Get-AppxPackageRelativeApplicationIds -Package <package_name>

Get-AppxPackageApplicationUserModelIds -Package <package_name>

Invoke-AppxPackageApplication -Package <package_name>
Invoke-AppxPackageApplication -Package <package_name> -AppId <app_id> -Arguments <args>
Invoke-AppxPackageApplication -Package <package_name> -AppId <app_id> -FilePath <file_path>
Invoke-AppxPackageApplication -Package <package_name> -AppId <app_id> -Uri <app_uri>
Invoke-AppxPackageApplication -Package <package_name> -AppId <app_id> -FilePath <file_path> -AssociationType File -AssociationKeyword <filename_ext>

Example:
Invoke-AppxPackageApplication -Package *nanazip* -AppId NanaZip.Modern -FilePath .\test.7z -AssociationType File -AssociationKeyword .7z
