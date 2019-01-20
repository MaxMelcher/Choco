$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Set-Variable -Option Constant -Scope Script -Name msiOpenDatabaseModeReadOnly -Value 0
Set-Variable -Option Constant -Scope Script -Name msiOpenDatabaseModeTransact -Value 1
Set-Variable -Option Constant -Scope Script -Name msiTransformErrorNone -Value 0
Set-Variable -Option Constant -Scope Script -Name msiTransformValidationNone -Value 0

function Ensure-RequiredPowerShellVersionPresent
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)] [version] $RequiredVersion
    )

    # 3.0 is the absolute minimum requirement, but future packages might require a newer version
    if ($PSVersionTable -eq $null -or $PSVersionTable.PSVersion -lt [version]$RequiredVersion)
    {
        throw "Azure PowerShell requires PowerShell version $RequiredVersion or greater. You can install it using the 'powershell' package." 
    }
    else
    {
        Write-Debug "Running on PowerShell $RequiredVersion or later (actually: $($PSVersionTable.PSVersion))"
    }
}

function Test-AzInstalled
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)] [version] $RequiredVersion
    )

    $newestModule = Get-Module -Name Az.* -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1
    if ($newestModule -ne $null -and $newestModule.Version -ge $RequiredVersion)
    {
        Write-Host "Azure PowerShell (Az Module) version $RequiredVersion or later is already installed (detected module $($newestModule.Name) version $($newestModule.Version))."
        return $true
    }
    else
    {
        if ($newestModule -ne $null)
        {
            Write-Debug "Azure PowerShell (Az Module) version $RequiredVersion or later is not installed (detected module $($newestModule.Name) version $($newestModule.Version))."
        }
        else
        {
            Write-Debug "Azure PowerShell (Az Module) version $RequiredVersion or later is not installed (no modules detected)."
        }

        return $false
    }
}
