function Get-AppxPackageRelativeApplicationIds {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $Package
    )
    
    process {
        $appxPackage = if ($Package -is [Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage]) {
            $Package
        }
        else {
            Get-AppxPackage -Name $Package -ErrorAction SilentlyContinue
        }
        
        if (-not $appxPackage) {
            return
        }
        
        $manifestPath = Join-Path -Path $appxPackage.InstallLocation -ChildPath "AppxManifest.xml"
        
        if (-not (Test-Path -LiteralPath $manifestPath)) {
            Write-Error "AppxManifest.xml not found at: $manifestPath"
            return
        }
        
        try {
            $xml = [xml](Get-Content -Path $manifestPath -Raw -ErrorAction Stop)
            
            $xml.Package.Applications.Application | ForEach-Object {
                if ($_.Id) {
                    $_.Id
                }
            }
        }
        catch {
            Write-Error "Error processing XML: $_"
        }
    }
}

function Get-AppxPackageApplicationUserModelIds {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $Package
    )
    
    process {
        $appxPackage = if ($Package -is [Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage]) {
            $Package
        }
        else {
            Get-AppxPackage -Name $Package -ErrorAction SilentlyContinue
        }
        
        if (-not $appxPackage) {
            return
        }
        
        $packageFamilyName = $appxPackage.PackageFamilyName
        
        $relativeAppIds = Get-AppxPackageRelativeApplicationIds -Package $appxPackage
        
        $aumids = foreach ($appId in $relativeAppIds) {
            "${packageFamilyName}!${appId}"
        }
        
        return $aumids
    }
}

function Invoke-ShellExecuteEx {
    param(
        [string]$FilePath,
        [string]$Arguments,
        [string]$WorkingDirectory,
        [string]$Verb,
        [string]$Class,
        [int]$ShowWindow = 1  # SW_SHOWNORMAL
    )

    if (-not ("BlueFire.AppxPackageLauncher.ShellWrapper" -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace BlueFire.AppxPackageLauncher
{
    public class ShellWrapper
    {
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct SHELLEXECUTEINFO
        {
            public int cbSize;
            public uint fMask;
            public IntPtr hwnd;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpVerb;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpFile;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpParameters;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpDirectory;
            public int nShow;
            public IntPtr hInstApp;
            public IntPtr lpIDList;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpClass;
            public IntPtr hkeyClass;
            public uint dwHotKey;
            public IntPtr hIcon;
            public IntPtr hProcess;
        }

        public const int SW_SHOWNORMAL = 1;
        public const uint SEE_MASK_INVOKEIDLIST = 0xC;
        public const uint SEE_MASK_CLASSNAME = 0x1;
        public const uint SEE_MASK_NOCLOSEPROCESS = 0x40;
        public const uint SEE_MASK_NOASYNC = 0x100;

        [DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool ShellExecuteEx(ref SHELLEXECUTEINFO lpExecInfo);
        
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern uint GetProcessId(IntPtr Process);
    }
}
"@ -ErrorAction SilentlyContinue
    }

    $shellExecInfo = New-Object BlueFire.AppxPackageLauncher.ShellWrapper+SHELLEXECUTEINFO
    $shellExecInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($shellExecInfo)
    $shellExecInfo.lpFile = $FilePath
    $shellExecInfo.lpParameters = $Arguments
    $shellExecInfo.lpDirectory = $WorkingDirectory
    $shellExecInfo.lpVerb = $Verb
    $shellExecInfo.nShow = $ShowWindow
    $shellExecInfo.fMask = [BlueFire.AppxPackageLauncher.ShellWrapper]::SEE_MASK_NOCLOSEPROCESS -bor [BlueFire.AppxPackageLauncher.ShellWrapper]::SEE_MASK_NOASYNC

    if (-not [string]::IsNullOrEmpty($Class)) {
        $shellExecInfo.lpClass = $Class
        $shellExecInfo.fMask = $shellExecInfo.fMask -bor [BlueFire.AppxPackageLauncher.ShellWrapper]::SEE_MASK_CLASSNAME
    }

    $result = [BlueFire.AppxPackageLauncher.ShellWrapper]::ShellExecuteEx([ref]$shellExecInfo)
    
    if (-not $result) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "ShellExecuteEx failed with error code: $errorCode"
    }

    $processId = [BlueFire.AppxPackageLauncher.ShellWrapper]::GetProcessId($shellExecInfo.hProcess)

    if ($processId -gt 0) {
        return (Get-Process -Id $processId)
    }
}

function Start-PackagedApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppUserModelId,
        [string]$Arguments = "",
        [switch]$NoSplashScreen,
        [switch]$NoErrorUI
    )
    
    # 确保必要的 COM 接口已定义
    if (-not ("BlueFire.AppxPackageLauncher.ApplicationActivationManager" -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace BlueFire.AppxPackageLauncher
{
    [ComImport, Guid("2E941141-7F97-4756-BA1D-9DECDE894A3D")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IApplicationActivationManager
    {
        IntPtr ActivateApplication([MarshalAs(UnmanagedType.LPWStr)] string appUserModelId, 
                                   [MarshalAs(UnmanagedType.LPWStr)] string arguments, 
                                   ActivateOptions options, 
                                   out uint processId);
    }

    [Flags]
    public enum ActivateOptions
    {
        None = 0,
        DesignMode = 0x1,
        NoErrorUI = 0x2,
        NoSplashScreen = 0x4
    }

    [ComImport, Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")]
    [ClassInterface(ClassInterfaceType.None)]
    public class ApplicationActivationManager {}

    public class ApplicationActivationManagerFactory
    {
        public static IntPtr ActivateApplication(string appUserModelId, 
            string arguments, 
            ActivateOptions options, 
            out uint processId)
        {
            var factory = (IApplicationActivationManager)(object)(new ApplicationActivationManager());
            return factory.ActivateApplication(appUserModelId, arguments, options, out processId);
        }
    }
}
"@ -ErrorAction SilentlyContinue
    }

    $options = [BlueFire.AppxPackageLauncher.ActivateOptions]::None
    if ($NoSplashScreen) { $options = $options -bor [BlueFire.AppxPackageLauncher.ActivateOptions]::NoSplashScreen }
    if ($NoErrorUI) { $options = $options -bor [BlueFire.AppxPackageLauncher.ActivateOptions]::NoErrorUI }

    $processId = 0
    $null = [BlueFire.AppxPackageLauncher.ApplicationActivationManagerFactory]::ActivateApplication($AppUserModelId, $Arguments, $options, [ref]$processId)
    
    if ($processId -gt 0) {
        return (Get-Process -Id $processId)
    }
}

function Get-AppAssociationProgId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$AppUserModelId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("File", "Protocol")]
        [string]$AssociationType,
        
        [Parameter(Mandatory = $true)]
        [string]$AssociationKeyword
    )

    begin {
        $registeredAppsPath = "HKCU:\SOFTWARE\RegisteredApplications\PackagedApps"
    }

    process {
        try {
            $assocPath = Get-ItemPropertyValue -Path $registeredAppsPath -Name $AppUserModelId -ErrorAction Stop
            
            $subPath = if ($AssociationType -eq "File") { "FileAssociations" } else { "URLAssociations" }
            $targetPath = "HKCU:\$assocPath\$subPath"
            
            Get-ItemPropertyValue -Path $targetPath -Name $AssociationKeyword -ErrorAction Stop
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            return
        }
        catch {
            return
        }
    }
}

function Invoke-AppxPackageApplication {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $Package,
        [string]$AppId,
        [string]$FilePath,
        [string]$Uri,
        [ValidateSet("File", "Protocol")][string]$AssociationType,
        [string]$AssociationKeyword,
        [string]$Arguments
    )

    process {
        $appxPackage = if ($Package -is [Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage]) {
            $Package
        }
        else {
            Get-AppxPackage -Name $Package -ErrorAction SilentlyContinue
        }
        
        if (-not $appxPackage) {
            return
        }
        
        if (-not $AppId) {
            $AppIds = @(Get-AppxPackageRelativeApplicationIds $appxPackage)
            if ($AppIds.Count -gt 0) {
                if ($AppIds.Count -eq 1) {
                    $AppId = $AppIds[0]
                }
                else {
                    $errorMessage = "Multiple application IDs found in this package. Please specify which AppId to launch:`n"
                    $errorMessage += $AppIds | ForEach-Object { " - $_" } | Out-String
                    Write-Error $errorMessage.Trim()
                    return
                }
            }
        }

        $AUMID = "$($appxPackage.PackageFamilyName)!$($AppId)"
        $process = $null

        if (-not $AssociationType) {
            if ($FilePath) {
                $AssociationType = "File"
                $AssociationKeyword = [System.IO.Path]::GetExtension($FilePath)
            }
            elseif ($Uri) {
                $AssociationType = "Protocol"
                $AssociationKeyword = (New-Object -TypeName System.Uri -ArgumentList @($Uri)).Scheme;
            }
        }

        if ($AssociationType) {
            if ($AssociationKeyword) {
                $ProgId = (Get-AppAssociationProgId -AppUserModelId $AUMID -AssociationType $AssociationType -AssociationKeyword $AssociationKeyword)
                if ($ProgId) {
                    $process = (Invoke-ShellExecuteEx -FilePath $FilePath -Class $ProgId -Arguments $Arguments)
                }   
            }
        }
        else {
            $process = (Start-PackagedApp -AppUserModelId $AUMID -Arguments $Arguments)
        }
        
        return $process
    }
}

Export-ModuleMember -Function Get-AppxPackageRelativeApplicationIds -Alias Get-MsixPackageRelativeApplicationIds
Export-ModuleMember -Function Get-AppxPackageApplicationUserModelIds -Alias Get-MsixPackageApplicationUserModelIds
Export-ModuleMember -Function Invoke-AppxPackageApplication -Alias Invoke-MsixPackageApplication