Param(
  [Parameter(Mandatory)]
  [int]$numberOfNics = 1,
  [int]$addSshKey = 0,
  [int]$addCustomData = 1
)

# Make it interactive for the number of NIC
'parameters accepted,'
'[int]numberOfNics = number of nics of the instance (between 1 and 4)'
'[int]addSshKey = 1 for yes, 0 for no. If yes, your key must be provided in the corresponding line.'
'[string]vmsize = examples: Standard_F2s,Standard_F4s,Standard_F8s,Standard_F1,Standard_F2,Standard_F4,Standard_F8'
'`n'
echo "numberOfNics : $numberOfNics"


# Provide your basic profiles
$subscriptionID = "2f96c44c-cfb2-4621-bd36-65ba45185e0c"  <# Choose the subscription ID which is entitled to purchase marketplace products #>
$key = "123456789abcdefg$%#@!"                            <# random seed ; any strings will be fine #>

# Required variables
$resourceGroupName = "jkatorsgrp001"  <# Existing resource group name #>
$virtualNetworkName = "jkatovnet001"  <# Existing VNet name #>
$locationName = "northeurope"  <# Location #>
$user = "youradmin"
$password = 'Y0urPassw@rd'  <# Login password #>
$vmName = "jkatovmname001"  <# FortiGate-VM hostname #>
$vmsize = "Standard_F1"
$storageAccountName = "jkatostorage001"   <# Your storage account; make sure this account exists under the resource group you specified #>
$storageAccountKey = "IuPSY8i7yOr0NprLKdbbbo5mj3cDJAC4i/EquMIvtz4mU9xb2rJDCzZ4Ht5zg0EYW3EeCbHaqNXP1RwqXSHaBA==" <# Your Storage account key #>
$sourceVhd = "C:\Azure\vhds\fortios.vhd" <# Source VHD path on your PC #>
$destinationVhd = "https://jkatostorage001.blob.core.windows.net/jkatocontainer/fortios.vhd"  <# Copied destination VHD path in your container #>
$osDiskUri = "https://jkatostorage001.blob.core.windows.net/disks/fortigate.vhd" <# Actual OS boot disk created in your blob #>
$dataDiskUri = "https://jkatostorage001.blob.core.windows.net/disks/DataDisk.vhd"  <# Data disk placed in your blob #>

# This end point is not used for a local MIME file, meaning when $addCustomData = 1
$webendpoint = "https://jkatostorage001.blob.core.windows.net/configfiles" <# A container that will store cloud-init/bootstrapping text files #>

$osDiskName = $vmName + '_osDisk'
$dataDiskName = $vmName + '_datadisk'

# Passing the profiles
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$DebugPreference="Continue"
$keyData = ""
#$keyData = "ssh-rsa AAAAB3NzaC1yc2EAA...........84Km1/qscePDoXt youradmin"
$networkname1 = "port1"
$networkname2 = "port2"
$networkname3 = "port3"
$networkname4 = "port4"
$pipName = "yourpip1" <# Public IP address name #>

Add-AzureRmAccount
Select-AzureRmSubscription –SubscriptionId $SubscriptionId

# Upload your local vhd file to Azure - this is "required" - VHD has to be 2GB in size.
Write-Output "$(Get-Date -f $timeStampFormat) - Upload"
Add-AzureRmVhd -LocalFilePath $sourceVHD -Destination $destinationVHD -ResourceGroupName $resourceGroupName -NumberOfUploaderThreads 5	

# Find an existing VNet under an existing resource group
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName

# Create a public IP address
Write-Output "$(Get-Date -f $timeStampFormat) - Create new public ip address"
$publicIp = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $ResourceGroupName -Location $locationName -AllocationMethod Dynamic -force

# Define NICs   
if ($numberOfNics -eq 0){
    'please try again, number of nics should not be 0'
}
ElseIf ($numberOfNics -eq 1){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 1 nic"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
}
ElseIf ($numberOfNics -eq 2){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 2 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
}
ElseIf ($numberOfNics -eq 3){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 3 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
    $networkInterface3 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname3 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
}
ElseIf ($numberOfNics -eq 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - creating 4 nics"
    $networkInterface1 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname1 -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIp.Id -force
    $networkInterface2 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname2 -Location $locationName -SubnetId $virtualNetwork.Subnets[1].Id -force
    $networkInterface3 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname3 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
    $networkInterface4 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $networkname4 -Location $locationName -SubnetId $virtualNetwork.Subnets[2].Id -force
}
ElseIf ($numberOfNics -gt 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - please enter a number between 1 and 4"
}

$vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize
$password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$securePassword
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword) 
$cred

$addCustomData
If ($addCustomData -eq 1) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add MIME file"
  $customdataFile= "C:\Azure\misc\azureinit.conf"
  
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
  }  ElseIf($addCustomData -eq 2) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add License only"
  $customdataFile= "C:\Azure\misc\license.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
  Write-Host $customdataFile
  Write-Host $customdataContent
  Write-Host ($vmConfig | Format-Table | Out-String)
  $vmConfig.OSProfile.CustomData
}   ElseIf($addCustomData -eq 3) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add FortiGate CLI only"
  $customdataFile= "C:\Azure\misc\config.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
}   ElseIf($addCustomData -eq 0) {
  Write-Output "$(Get-Date -f $timeStampFormat) - No custom data"
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux
  $vmConfig
} ElseIf($addCustomData -eq 4) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add FortiGate CLI only on web endpoint"
  echo "{
    `"config-url`":`"$webendpoint/config.txt`"
}

" | Out-File -filepath C:\Azure\misc\azurebootstrap\webconfig.txt
  $customdataFile= "C:\Azure\misc\azurebootstrap\webconfig.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
}ElseIf($addCustomData -eq 5) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add License only on web endpoint"
  echo "{
    `"license-url`":`"$webendpoint/license.txt`"
}

" | Out-File -filepath C:\Azure\misc\azurebootstrap\license.txt
  $customdataFile= "C:\Azure\misc\azurebootstrap\license.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
}ElseIf($addCustomData -eq 6) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add both CLI and License on web endpoint"
  echo "{
    `"license-url`":`"$webendpoint/license.txt`",
    `"config-url`":`"$webendpoint/config.txt`"
}

" | Out-File -filepath C:\Azure\misc\azurebootstrap\licconfig.txt
  $customdataFile= "C:\Azure\misc\azurebootstrap\licconfig.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
}ElseIf($addCustomData -eq 7) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add MIME file on web endpoint"
  echo "{
    `"mime-url`":`"$webendpoint/azureinit.conf`"
}

" | Out-File -filepath C:\Azure\misc\azurebootstrap\webmime.txt
  $customdataFile= "C:\Azure\misc\azurebootstrap\webmime.txt"
  $customdataContent = Get-Content $customdataFile -Raw
  $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -ComputerName $vmname -Credential $cred -Linux -CustomData $customdataContent
}


# Setup Disks - 1st line: OS disk, 2nd line: data disk of 30GB in size 
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -CreateOption fromimage -Linux -SourceImageUri $destinationVhd -VhdUri $osDiskUri -Name $osDiskName
$vmConfig = Add-AzureRmVmDataDisk -vm $vmConfig -Name $dataDiskName -Caching 'ReadWrite' -DiskSizeInGB 30 -Lun 0 -VhdUri $dataDiskUri -CreateOption Empty

# Add NICs
if ($numberOfNics -eq 0){
    Write-Output "$(Get-Date -f $timeStampFormat) - please try again, number of nics should not be 0"
}
ElseIf ($numberOfNics -eq 1){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 1 nic"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
}
ElseIf ($numberOfNics -eq 2){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 2 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
}
ElseIf ($numberOfNics -eq 3){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 3 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface3.Id
}
ElseIf ($numberOfNics -eq 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - applying 4 nics"
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface1.Id -Primary
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface2.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface3.Id
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface4.Id 
}
ElseIf ($numberOfNics -gt 4){
    Write-Output "$(Get-Date -f $timeStampFormat) - please enter a number between 1 and 4"
}


If ($addSshKey -eq 1) {
  Write-Output "$(Get-Date -f $timeStampFormat) - Add sshkey for tester"
  Add-AzureRmVMSshPublicKey -VM $vmConfig -KeyData $keyData -Path "/home/$user/.ssh/authorized_keys"
  }  Else {
  Write-Output "$(Get-Date -f $timeStampFormat) - No sshkey"
} 

# Create a new FortiGate-VM
Write-Output "$(Get-Date -f $timeStampFormat) - creating vm"
New-AzureRmVM -VM $vmConfig -Location $locationName -ResourceGroupName $resourceGroupName