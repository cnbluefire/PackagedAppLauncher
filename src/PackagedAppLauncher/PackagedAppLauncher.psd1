#
# 模块“PackagedAppLauncher”的模块清单
#
# 生成者: blue-
#
# 生成时间: 2025/6/17
#

@{

# 与此清单关联的脚本模块或二进制模块文件。
RootModule = 'PackagedAppLauncher.psm1'

# 此模块的版本号。
ModuleVersion = '1.0.6'

# 支持的 PSEditions
# CompatiblePSEditions = @()

# 用于唯一标识此模块的 ID
GUID = '294f2242-edf5-498e-97d9-08d1ce3a8d15'

# 此模块的作者
Author = 'blue-'

# Company or vendor of this module
CompanyName = 'Unknown'

# 此模块的版权声明
Copyright = '(c) 2025 blue-。保留所有权利。'

# 此模块所提供功能的说明
Description = 'Invoke-AppxPackageApplication'

# 此模块要求的 Windows PowerShell 引擎的最低版本
# PowerShellVersion = ''

# 此模块要求的 Windows PowerShell 主机的名称
# PowerShellHostName = ''

# 此模块要求的 Windows PowerShell 主机的最低版本
# PowerShellHostVersion = ''

# 此模块要求使用的最低 Microsoft .NET Framework 版本。此先决条件仅对 PowerShell Desktop 版本有效。
# DotNetFrameworkVersion = ''

# 此模块要求使用的最低公共语言运行时(CLR)版本。此先决条件仅对 PowerShell Desktop 版本有效。
# CLRVersion = ''

# 此模块要求的处理器体系结构(无、X86、Amd64)
# ProcessorArchitecture = ''

# 必须在导入此模块之前先导入全局环境中的模块
# RequiredModules = @()

# 导入此模块之前必须加载的程序集
# RequiredAssemblies = @()

# 导入此模块之前运行在调用方环境中的脚本文件(.ps1)。
# ScriptsToProcess = @()

# 导入此模块时要加载的类型文件(.ps1xml)
# TypesToProcess = @()

# 导入此模块时要加载的格式文件(.ps1xml)
# FormatsToProcess = @()

# 将作为 RootModule/ModuleToProcess 中所指定模块的嵌套模块导入的模块
# NestedModules = @()

# 要从此模块中导出的函数。为了获得最佳性能，请不要使用通配符，不要删除该条目。如果没有要导出的函数，请使用空数组。
FunctionsToExport = @("Get-AppxPackageRelativeApplicationIds", "Get-AppxPackageApplicationUserModelIds", "Invoke-AppxPackageApplication")

# 要从此模块中导出的 cmdlet。为了获得最佳性能，请不要使用通配符，不要删除该条目。如果没有要导出的 cmdlet，请使用空数组。
CmdletsToExport = @()

# 要从此模块中导出的变量
VariablesToExport = @()

# 要从此模块中导出的别名。为了获得最佳性能，请不要使用通配符，不要删除该条目。如果没有要导出的别名，请使用空数组。
AliasesToExport = @("Get-MsixPackageRelativeApplicationIds", "Get-AppxPackageRAIDs", "Get-MsixPackageRAIDs", "Get-MsixPackageApplicationUserModelIds", "Get-AppxPackageAUMIDs", "Get-MsixPackageAUMIDs", "Invoke-MsixPackageApplication", "Invoke-AppxPackageApp", "Invoke-MsixPackageApp")

# 要从此模块导出的 DSC 资源
# DscResourcesToExport = @()

# 与此模块一起打包的所有模块的列表
# ModuleList = @()

# 与此模块一起打包的所有文件的列表
# FileList = @()

# 要传递到 RootModule/ModuleToProcess 中指定的模块的专用数据。这还可能包含 PSData 哈希表以及 PowerShell 使用的其他模块元数据。
PrivateData = @{

    PSData = @{

        # 应用于此模块的标记。这些标记有助于在联机库中执行模块发现。
        # Tags = @()

        # 指向此模块的许可证的 URL。
        LicenseUri = 'https://github.com/cnbluefire/PackagedAppLauncher/blob/main/LICENSE'

        # 指向此项目的主网站的 URL。
        ProjectUri = 'https://github.com/cnbluefire/PackagedAppLauncher'

        # 指向表示此模块的图标的 URL。
        # IconUri = ''

        # 此模块的 ReleaseNotes
        # ReleaseNotes = ''

    } # PSData 哈希表末尾

} # PrivateData 哈希表末尾

# 此模块的 HelpInfo URI
# HelpInfoURI = ''

# 从此模块中导出的命令的默认前缀。可以使用 Import-Module -Prefix 覆盖默认前缀。
# DefaultCommandPrefix = ''

}

