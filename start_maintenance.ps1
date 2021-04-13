Param (
    [Parameter(Mandatory)][string]$HostName,
    [Parameter(Mandatory)][string]$RedirectTargetFQDN
)

$ErrorActionPreference = 'Stop'

function ComponentDrain {
    Set-ServerComponentState $HostName -Component HubTransport -State Draining -Requester Maintenance
    Restart-Service MSExchangeTransport
    Set-ServerComponentState $HostName -Component UMCallRouter -State Draining -Requester Maintenance
    Redirect-Message -Server $HostName -Target $RedirectTargetFQDN
}
function DAGSuspend {
    Suspend-ClusterNode $HostName
    Set-MailboxServer $HostName -DatabaseCopyActivationDisabledAndMoveNow $True
    Set-MailboxServer $HostName -DatabaseCopyAutoActivationPolicy Blocked
}
function ComponentInactive {
    Set-ServerComponentState $HostName -Component ServerWideOffline -State Inactive -Requester Maintenance
}
$confirm = Read-Host "Are you sure you wan to proceed? [y/n]"
if (($confirm -ne "y") -and ($confirm -ne "yes")) {
    Write-Output "nothing done."
    exit
}

ComponentDrain
DAGSuspend
ComponentInactive

# 「Monitoring」および「RecoverActionsEnabled」以外の「State」が「Inactive」になっていること
Get-ServerComponentState $HostName | Format-Table Component, State -AutoSize
# DatabaseCopyActivationDisabledAndMoveNow」が「True」、「DatabaseCopyAutoActivationPolicy」が「Blocked」であること
Get-MailboxServer $HostName | Format-Table DatabaseCopy* -AutoSize
# State」が「Paused」になっていること
Get-ClusterNode $HostName | Format-List
Get-Queue