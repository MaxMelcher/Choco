import-module au

$releases = 'https://github.com/Azure/azure-powershell/releases'

function global:au_SearchReplace {
    @{
        '.\tools\ChocolateyInstall.ps1' = @{
            '(^\s*\$moduleVersion\s*=\s*\[version\])(''.*'')' = "`$1'$($Latest.SoftwareVersion)'"
            '(^\s*\$url\s*=\s*)(''.*'')'                    = "`$1'$($Latest.Url32)'"
            '(^\s*\$checksum\s*=\s*)(''.*'')'               = "`$1'$($Latest.Checksum32)'"
            '(^\s*\$checksumType\s*=\s*)(''.*'')'           = "`$1'$($Latest.ChecksumType32)'"
        }
    }
}

function global:au_BeforeUpdate() {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.Url32
    $Latest.ChecksumType32 = 'SHA256'
}

function global:au_AfterUpdate { 

}

function global:au_GetLatest {

    $downloadPage = Invoke-WebRequest -Uri $releases -UseBasicParsing
        
    # https://github.com/Azure/azure-powershell/releases/download/v1.1.0-January2019/Az-Cmdlets-1.1.0.25353-x64.msi
    # https://github.com/Azure/azure-powershell/releases/download/
    
    $rx = '^/Azure/azure-powershell/releases/download/[^/]+/Az-Cmdlets-(?<v>\d+\.\d+\.\d+\.\d+)-x64.msi$'
    
    $info = $downloadPage.Links | Select-Object -ExpandProperty href | Select-String -Pattern $rx | Select-Object -Property 'Line', @{ Name = 'Version'; Expression = { [version]$_.Matches[0].Groups['v'].Value } } | Sort-Object -Property 'Version' -Descending | Select-Object -First 1

    return @{
        SoftwareVersion = $info.Version
        Version = $info.Version
        Url32   = "https://github.com$($info.Line)"
    }
}

# -NoCheckChocoVersion $true
update -ChecksumFor none
