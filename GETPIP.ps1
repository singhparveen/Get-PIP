$filepath = ".\pipresources.json"
$json = @()
$ipAddress = @()

$context = Get-AzContext
if (!$context) {
    Connect-AzAccount
    $context = Get-AzContext
}
Write-Host "Context Retrieved Successfully."
Write-Host $context.Name

function FetchResources {   
    if ($context) {
        $pipResource = @()
        $allSub = Get-AzSubscription
        $allSub | foreach {
            Set-AzContext -SubscriptionId $_.Id
            $pipResource += Get-AzPublicIpAddress
        }
        $pipResource | ConvertTo-Json | Out-File pipresources.json
        Find-IPAddress -ipAddr $ipAddress
    }
    else {
        Write-Host "Please Login first in order to continue"
    }
}

function Find-IPAddress {
    param (
        [Parameter(Mandatory)]
        [String]$ipAddr
    )
    $ipAddress = $ipAddr
    if (Test-Path $filepath) {
        $json = Get-Content -Path $filepath | ConvertFrom-Json
        if ($json.Count -ge 1) {
            $query = $json | where { $_.IpAddress -like "$ipAddress" }
            Write-Host "Resource using IP" $ipAddress ":"
            $query | Format-Table Name, ResourceGroupName, IpAddress, Id
        }
        else {
            Remove-Item -Path $filepath
            FetchResources
        }
    }
    else {
        FetchResources
    }
}       
#run function
Find-IPAddress