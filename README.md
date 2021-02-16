# Basic ARM_VirtualMachine ReadMe

This is used to add a basic virtual machine to a previously setup Azure virtual Network.

Assumes that you already have Virtual Network Setup with NSGs assigned to the VNet and a Log Analytics workspace.

### Requires the following to be already setup

    Virtual Network Resource Group
    Virtual Network (Name)
    Network Security Group (Name)
    Log Analytics Resource Group
    Log Analytics Workspace (Name)

### Steps to deploy with PowerShell commands

<code></code><code>PowerShell

    # Variables for deployment
    $tenant = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    $subscription = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    $resourceGroupName = 'PROD-FILESERVER01-RG'
    $location = 'eastus"
    $tag = @{ Environment = 'PROD'; Portfolio = 'FinanceDept'; Application = 'FileServer';  }
    $templateFilePath = '<Path>\azuredeploy.json'
    $parametersFilePath = '<Path>\azuredeploy.parameters.json'

    # Connect to Azure
    Connect-AzAccount -Tenant $tenant -Subscription $subscription

    # Build the Resource Group
    New-AzResourceGroup -Name $resourceGroupName -Location "eastus" -Tag $tag

    # Test the Parameters and Template
    Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Mode Incremental -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose

    # Build the Parameters and Template
    New-AzResourceGroupDeployment -Name "Deploy01" -ResourceGroupName $resourceGroupName -Mode Incremental -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Force -Verbose

    # Change the NIC to Static
    $Nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name 'servername01-nic'
    $Nic.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
    Set-AzNetworkInterface -NetworkInterface $Nic



    # (if you have a DSC script) 
    
    # Deploy DSC Script to Azure Automation Account
    $automationAccountName = 'PROD-Automation'
    Import-AzAutomationDscConfiguration -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -SourcePath ".\servername01.ps1" -Force -Published -Tag $tag
    $CompilationJob = Start-AzAutomationDscCompilationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -ConfigurationName 'servername01'
    while ($null -eq $CompilationJob.EndTime -and $null -eq $CompilationJob.Exception) {
        $CompilationJob = $CompilationJob | Get-AzAutomationDscCompilationJob
        Start-Sleep -Seconds 3
    }
    $CompilationJob | Get-AzAutomationDscCompilationJobOutput -Stream Any

    # Register the server to the Azure Automation Account so it gets the DSC
    Register-AzAutomationDscNode -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -AzureVMName 'servername01' -NodeConfigurationName "servername01.localhost"

</code><code></code>

