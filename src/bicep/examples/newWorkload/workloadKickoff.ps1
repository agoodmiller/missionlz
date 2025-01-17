$data=Get-Content -Path parameters.json | ConvertFrom-Json

$output=az deployment sub show `
  --name $data.deploymentName `
  --query "properties.outputs"| ConvertFrom-Json 

$hubSubscriptionId = $output.hub.value.subscriptionId
$hubResourceGroupName = $output.hub.value.resourceGroupName
$hubVirtualNetworkName = $output.hub.value.virtualNetworkName
$hubVirtualNetworkResourceId = $output.hub.value.virtualNetworkResourceId
$logAnalyticsWorkspaceResourceId = $output.logAnalyticsWorkspaceResourceId.value
$firewallPrivateIPAddress = $output.firewallPrivateIPAddress.value


Foreach ($item in $data.tiers.Value) 
{ 
	write-host $item.workloadName
	
	$templateFileWorkload = "./newWorkload.bicep"
	$tierParams = " --template-file $templateFileWorkload"
	
	if ($item.subscriptionID.Length -gt 0){$tierParams = $tierParams + " --subscription "+$item.subscriptionID}	
	if ($item.location.Length -gt 0){$tierParams = $tierParams + " --location "+$item.location}	
	if ($item.workloadName.Length -gt 0){$tierParams = $tierParams + " --name "+$item.workloadName}
	
	$tierParams = $tierParams + " --parameters"
	$outputfile = '{"hubSubscriptionId": "'+$hubSubscriptionId+'","hubResourceGroupName":"'+$hubResourceGroupName+'","hubVirtualNetworkName":"'+$hubVirtualNetworkName+'", "hubVirtualNetworkResourceId":"'+$hubVirtualNetworkResourceId+'","logAnalyticsWorkspaceResourceId":"'+$logAnalyticsWorkspaceResourceId+'","firewallPrivateIPAddress":"'+$firewallPrivateIPAddress+'"}'
	$outputfile	| Out-File -FilePath ..\deploymentVariables.json 
	write-host $outputfile 
	
	if ($item.workloadName.Length -gt 0){$tierParams = $tierParams + " workloadName="+$item.workloadName}
	if ($hubSubscriptionId.Length -gt 0){$tierParams = $tierParams + " hubSubscriptionId="+$hubSubscriptionId}
	if ($hubResourceGroupName.Length -gt 0){$tierParams = $tierParams + " hubResourceGroupName="+$hubResourceGroupName}
	if ($hubVirtualNetworkName.Length -gt 0){$tierParams = $tierParams + " hubVirtualNetworkName="+$hubVirtualNetworkName}
	if ($hubVirtualNetworkResourceId.Length -gt 0){$tierParams = $tierParams + " hubVirtualNetworkResourceId="+$hubVirtualNetworkResourceId}
	if ($logAnalyticsWorkspaceResourceId.Length -gt 0){$tierParams = $tierParams + " logAnalyticsWorkspaceResourceId="+$logAnalyticsWorkspaceResourceId}
	if ($firewallPrivateIPAddress.Length -gt 0){$tierParams = $tierParams + " firewallPrivateIPAddress="+$firewallPrivateIPAddress}
	
	if ($item.resourceGroupName.Length -gt 0) {$tierParams = $tierParams + " resourceGroupName="+$item.resourceGroupName}
	if ($item.tags.Length -gt 0) {$tierParams = $tierParams + " tags="+$item.tags}
	if ($item.virtualNetworkName.Length -gt 0) {$tierParams = $tierParams + " virtualNetworkName="+$item.virtualNetworkName}
	if ($item.virtualNetworkAddressPrefix.Length -gt 0) {$tierParams = $tierParams + " virtualNetworkAddressPrefix="+$item.virtualNetworkAddressPrefix}
	if ($item.virtualNetworkDiagnosticsLogs.Length -gt 0) {$tierParams = $tierParams + " virtualNetworkDiagnosticsLogs="+$item.virtualNetworkDiagnosticsLogs}
	if ($item.virtualNetworkDiagnosticsMetrics.Length -gt 0) {$tierParams = $tierParams + " virtualNetworkDiagnosticsMetrics="+$item.virtualNetworkDiagnosticsMetrics}
	if ($item.networkSecurityGroupName.Length -gt 0) {$tierParams = $tierParams + " networkSecurityGroupName="+$item.networkSecurityGroupName}
	if ($item.networkSecurityGroupRules.Length -gt 0) {$tierParams = $tierParams + " networkSecurityGroupRules="+$item.networkSecurityGroupRules}
	if ($item.networkSecurityGroupDiagnosticsLogs.Length -gt 0) {$tierParams = $tierParams + " networkSecurityGroupDiagnosticsLogs="+$item.networkSecurityGroupDiagnosticsLogs}
	if ($item.networkSecurityGroupDiagnosticsMetrics.Length -gt 0) {$tierParams = $tierParams + " networkSecurityGroupDiagnosticsMetrics="+$item.networkSecurityGroupDiagnosticsMetrics}
	if ($item.subnetName.Length -gt 0) {$tierParams = $tierParams + " subnetName="+$item.subnetName}
	if ($item.subnetAddressPrefix.Length -gt 0) {$tierParams = $tierParams + " subnetAddressPrefix="+$item.subnetAddressPrefix}
	if ($item.subnetServiceEndpoints.Length -gt 0) {$tierParams = $tierParams + " subnetServiceEndpoints="+$item.subnetServiceEndpoints}
	if ($item.logStorageAccountName.Length -gt 0) {$tierParams = $tierParams + " logStorageAccountName="+$item.logStorageAccountName}
	if ($item.logStorageSkuName.Length -gt 0) {$tierParams = $tierParams + " logStorageSkuName="+$item.logStorageSkuName}
	if ($item.resourceIdentifier.Length -gt 0) {$tierParams = $tierParams + " resourceIdentifier="+$item.resourceIdentifier}

	
	
	$createSecondaryTier = "az deployment sub create $tierParams"
	write-host $createSecondaryTier

	Invoke-Expression $createSecondaryTier
	
}
  