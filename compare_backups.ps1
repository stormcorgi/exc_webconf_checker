Param(
    [parameter(Mandatory)][string]$beforefolder,
    [parameter(Mandatory)][string]$afterfolder
)

function isNullStr ($str) {
    return [string]::IsNullOrEmpty($str)
}

Get-ChildItem -r -File $beforefolder -Name | ForEach-Object {
    $beforep = Test-Path before\$_
    $afterp = Test-Path after\$_

    if (!($beforep)) { 
        Write-Output "before\$_ didn't exist."
        continue
    }

    if (!($afterp)) { 
        Write-Output "after\$_ didn't exist."
        continue
    }

    $beforeStr = Get-Content before\$_
    $afterStr = Get-Content after\$_

    if (isNullStr $beforeStr) {
        Write-Output "before\$_ is null."
    }

    if (isNullStr $afterStr) {
        Write-Output "after\$_ is null."
    }

    if (isNullStr $beforeStr -or isNullStr $afterStr) {
        Write-Output "null file can't compare!"
        continue
    } 

    if (!(isNullStr $beforeStr) -and !(isNullStr $afterStr)) {
        Write-Output "---$_---"
        Compare-Object $beforeStr $afterStr
        Write-Output "--------------"
    } 
}