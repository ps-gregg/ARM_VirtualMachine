
# Set the values for Subscription and Tenant
$SubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
$TenantId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

# Set the values for ResourceGroup, Location, Parameters, Template and Tags
$resourceGroupName = 'PROD-EAST-RG'
$location = 'eastus'
$templateFilePath = '.\azuredeploy.template.json'
$parametersFilePath = '.\azuredeploy.parameters.json'
$tag = @{ Environment = 'PROD'; 
    Portfolio         = 'Databases'; 
    Application       = 'SQLDatabase'; 
}

# Set the context to the correct subscription
Set-AzContext  -Subscription $SubscriptionId -TenantId $TenantId

# Build the Resource Group
If ($null -eq (Get-AzResourceGroup -Name $resourceGroupName -ea SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tag
}

# Test the Parameters and Template
Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Mode Incremental -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose

# Build the Parameters and Template
New-AzResourceGroupDeployment -Name "PROD-EAST-RG.servername01" -ResourceGroupName $resourceGroupName -Mode Incremental -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Force -Verbose

# Change the NIC to Static
$Nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name 'servername01-nic'
$Nic.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
Set-AzNetworkInterface -NetworkInterface $Nic


# Deploy DSC Script to Azure Automation Account
$automationAccountName = 'PROD-EAST-Automation'
$resourceGroupName = 'PROD-EAST-RG'
Import-AzAutomationDscConfiguration -AutomationAccountName $AutomationAccountName -ResourceGroupName $resourceGroupName -SourcePath ".\servername01.ps1" -Force -Published -Tag $tag
$CompilationJob = Start-AzAutomationDscCompilationJob -AutomationAccountName $AutomationAccountName -ResourceGroupName $resourceGroupName -ConfigurationName 'servername01'
while ($null -eq $CompilationJob.EndTime -and $null -eq $CompilationJob.Exception) {
    $CompilationJob = $CompilationJob | Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$CompilationJob | Get-AzAutomationDscCompilationJobOutput -Stream Any

# Register the server to the Azure Automation Account so it get the DSC
Register-AzAutomationDscNode -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -AzureVMName 'servername01' -NodeConfigurationName "servername01.localhost"
