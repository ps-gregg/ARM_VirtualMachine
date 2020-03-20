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
</code><code></code>

