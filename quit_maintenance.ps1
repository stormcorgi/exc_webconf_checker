Param(
    [Parameter(Mandatory)][string]$HostName
)

$ErrorActionPreference = 'stop'

function ComponentActivate {
    Set-ServerComponentState $HostName -Component ServerWideOffline -State Active -Requester Maintenance
    Set-ServerComponentState $HostName -Component UMCallRouter -State Active -Requester Maintenance
}

function DAGResume {
    Resume-ClusterNode $HostName
    Set-MailboxServer $HostName -DatabaseCopyActivationDisabledAndMoveNow $False
    Set-MailboxServer $HostName -DatabaseCopyAutoActivationPolicy Unrestricted
}

function HubTransportComponentActivate {
    Set-ServerComponentState $HostName -Component HubTransport -State Active -Requester Maintenance
    Restart-Service MSExchangeTransport
}

ComponentActivate
DAGResume
HubTransportComponentActivate

# ⇒ForwardSyncDaemon、ProvisioningRpsを除くすべての「State」が「Active」になっていること
Get-ServerComponentState $HostName | Format-Table Component, State -AutoSize
