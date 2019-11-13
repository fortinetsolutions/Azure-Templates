## This template set is designed for Azure PoC.  The following are created:
	- vnet with six subnets
	- Two public IPs. Both are attached to the FortiGate primary (WAN) VNIC
	- Partially configured FortiGate Virtual Appliance
  - Windows Server
  - Linux Server

Diagram:
---

![Example Diagram](https://raw.githubusercontent.com/fortinetsolutions/Azure-Templates/master/FortiGate/PoC/Diagram1.PNG)

---

To login to the FortiGate, use https or ssh and connect to publicIP1. The FortiGate has DNAT configurations to forward RDP using the same public IP to the Windows Server.  Additionally, SSH and HTTP are forwarded, using the secondary public IP, to the Linux Server.  There is a static route on the FortiGate to send all internal VNET traffic through port2.  Review the VIP and Policy configuration and compare with the settings on the Azure resources.  Notice the Azure User defined route table.  This will provide a good overview of how FortiGates participate in routing and forwarding traffic within the Azure VNET. 

For TCP or UDP ports that are not already used, you can create additional Virtual IPs and forward to other internal servers.  Alternatively, you can create another ipconfig on the FortiGate primary VNIC in Azure and associate a new public IP.  This will allow you to use the same protocols on standard ports again.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ffortinetsolutions%2FAzure-Templates%2Fmaster%2FFortiGate%2FPoC%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>