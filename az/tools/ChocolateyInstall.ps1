$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$packageName = 'az'
$moduleVersion = [version]'1.1.0.25353'
$url = 'https://github.com/Azure/azure-powershell/releases/download/v1.1.0-January2019/Az-Cmdlets-1.1.0.25353-x64.msi'
$checksum = 'bb21b283f3fea0081493f9c82f878088834d1c3e84c315dc3ebf29f63e181a63'
$checksumType = 'SHA256'

. (Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path) -ChildPath helpers.ps1)

Ensure-RequiredPowerShellVersionPresent -RequiredVersion '5.0'

if (Test-AzInstalled -RequiredVersion $moduleVersion)
{
    return
}

$scriptDirectory = $PSScriptRoot # safe to use because we test for PS 5.0+ earlier
$originalMsiLocalPath = Join-Path -Path $scriptDirectory -ChildPath "Az-Cmdlets.${moduleVersion}-x64.msi"

$downloadArguments = @{
    packageName = $packageName
    fileFullPath = $originalMsiLocalPath
    url = $url
    checksum = $checksum
    checksumType = $checksumType
}

Set-StrictMode -Off # unfortunately, builtin helpers are not guaranteed to be strict mode compliant
Get-ChocolateyWebFile @downloadArguments | Out-Null
Set-StrictMode -Version 2

$instArguments = @{
    packageName = $packageName
    installerType = 'msi'
    file = $originalMsiLocalPath
    silentArgs = '/Quiet /NoRestart /Log "{0}\{1}_{2:yyyyMMddHHmmss}.log"' -f $Env:TEMP, $packageName, (Get-Date)
    validExitCodes = @(
        0, # success
        3010 # success, restart required
    )
}

Set-StrictMode -Off
Install-ChocolateyInstallPackage @instArguments

Write-Warning 'You may need to close and reopen PowerShell before the Az modules become available.'
