This template set:
	- creates a vnet or uses an existing vnet of your selection.
	- creates or uses two public IPs connected as frontends to an Azure public load balancer.
    Note: you also have an option to not use a public IP
	- creates 2 FortiGates

In order to configure FortiGates:
  FortiGate-A:
    Connect via https to public IP1 or private IP if already connected to the vnet via ExpressRoute or Azure VPN (both of these IPs can be obtained from the portal)
    Connect via SSH on port 22 to public IP1 to directly access the CLI
  FortiGate-B:
    Connect via https to public IP2 or private IP if already connected to the vnet via ExpressRoute or Azure VPN (both of these IPs can be obtained from the portal)
    Connect via SSH on port 22 to public IP2 to directly access the CLI

The Azure Load Balancer only has management ports configured in the NAT rules.  For highly available access through the FortiGates, it's recommended that you use additional frontends and public IPs with floating IP load balance rules.  Then, you can configure Virtual IPs on the FortiGate to match the associated public IP.

When configuring the policies on the FortiGates to allow and forward traffic to internal hosts, it is recommended that you enable the NAT checkbox (this will S-NAT the packets to the IP of port2).  Doing this will enforce symmetric return.  It is possible to use FGSP instead of S-NAT, however this is not a generally recommended practice as it increases latency of the initial connection. For more information, see the included SessionSync file.

For information on using Azure SDN features to provide additional HA capability (for east/west and outbound connections) see https://fusecommunity.fortinet.com/p/fo/et/thread=2787