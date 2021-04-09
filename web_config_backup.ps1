Param(
    [parameter(Mandatory)][string]$OutputFolderName
)

if ($null -eq $env:exchangeinstallpath) {
    Write-Error "please exec on exchange server"
    exit 1
} elseif (!(Test-Path $env:exchangeinstallpath )) {
    Write-Error "environment path didn't exist. something wrong. "
    exit 1
}

$dirs = Get-ChildItem -r $env:exchangeinstallpath -Filter web.config -Name | ForEach-Object { Split-Path -Parent $_ }
$dirs = $dirs | Sort-Object -Unique

foreach ($d in $dirs) {
    robocopy $env:exchangeinstallpath\$d\\ .\$OutputFolderName\$d /s web.config
}

