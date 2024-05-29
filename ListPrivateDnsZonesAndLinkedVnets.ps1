# This Script will list all Private DNS Zones in a subscription and the Virtual Networks linked to them

# Ensure you have Azure CLI installed and authenticated
# Run `az login` if you are not authenticated

# Set the subscription context
$subscriptionId = "Put-The-Subscription-ID-Here"
az account set --subscription $subscriptionId

# Get all Private DNS Zones in the subscription
$dnsZones = az network private-dns zone list --output json | ConvertFrom-Json

# Create an array to store the results
$result = @()

foreach ($zone in $dnsZones) {
    $zoneName = $zone.name
    $resourceGroup = $zone.resourceGroup

    # Get all Virtual Networks linked to the current Private DNS Zone
    $linkedVnets = az network private-dns link vnet list --zone-name $zoneName --resource-group $resourceGroup --output json | ConvertFrom-Json

    foreach ($vnet in $linkedVnets) {
        $vnetName = $vnet.virtualNetwork.id.Split('/')[-1]
        $vnetResourceGroup = $vnet.virtualNetwork.id.Split('/')[4]
        $linkStatus = $vnet.registrationEnabled

        # Add the information to the result array
        $result += [PSCustomObject]@{
            ZoneName = $zoneName
            ZoneResourceGroup = $resourceGroup
            VNetName = $vnetName
            VNetResourceGroup = $vnetResourceGroup
            RegistrationEnabled = $linkStatus
        }
    }
}

# Output the result
$result | Format-Table -AutoSize

# Export the result to a CSV file with headers
$result | Export-Csv -Path "PrivateDnsZonesAndLinkedVnets.csv" -NoTypeInformation -Force
