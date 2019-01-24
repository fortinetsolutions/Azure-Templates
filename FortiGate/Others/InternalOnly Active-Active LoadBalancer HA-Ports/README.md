## Active/Active loadbalanced pair of standalone FortiGates for resilience and scale
The following resources are defined:
- vnet with two subnets
                or allows an existing vnet of your selection.  If using an existing vnet, it must already have 2 subnets.
                
- One internal load balancer with an HA Ports rule enabled to forward all traffic to the FortiGates' internal NICs
 
- Two FortiGates


No "Protected Subnet" is created within the VNET for testing or example purposes.  Recommended best practice would be to use peered VNETs rather than internal subnets.  Each peered VNET can easily be protected from other peered VNETs to provide isolation without the need for distributed and potentially confusing NSGs.  Further, this model provides best practice for Azure routing.  Each Peered VNET can be treated as a stub network, and thus only a default route (0.0.0.0/0) will be needed for the Azure UDR assigned to the subnets within the peered (aka Spoke) subnets.  Note: Azure now has an option to disable BGP route replication as part of UDR configuration.  This will remove any BGP routes which may be coming in via ExpressRoute or Azure VPN Gateways.

A best practice full deployment will look like the following diagram:
---

![Example Diagram](https://raw.githubusercontent.com/fortinetclouddev/FortiGate-HA-for-Azure/EastWestHA2.1/diagram2.png)

---

### In order to configure FortiGates:

    FortiGate-A:
    Connect via https on TCP port 8443 to private IP of subnet1
    Connect via SSH on port 22 to same IP to directly access the CLI
    FortiGate-B:
    Connect via https on TCP port 8443 to private IP of subnet1
    Connect via SSH on port 22 to same IP to directly access the CLI

If all traffic is going in/out of port 2, the Azure internal load balancer will maintain state and forward traffic symmetrically.  However, if necessary, you can also enable FGSP to allow asymmetric traffic flow.

If you do prefer to use FGSP for session synchronization.  Here's the recommended configuration:

    config system ha
        set session-pickup enable
        set session-pickup-connectionless enable
        set session-pickup-nat enable
        set session-pickup-expectation enable
        set override disable
    end

    config system cluster-sync
        edit 0
            set peerip 10.0.1.x
            set syncvd "root"
        next
    end

*Where x in 10.0.1.x is the IP of port1 of the opposite FortiGate

#### Routing Configuration

On the FortiGate, you will need a route to 168.63.129.16/32 out port2 with a gateway of the first IP of the transit subnet (in the diagram example 10.0.2.1).  This will allow port2 to respond to probe requests from the internal load balancer probe.  Note: You also need SSH enabled on port2 since the probe is set to test TCP connection on port 22.

In addition, you will need to add routes on the FortiGate to any "internal" subnets and VNETs, with the same gateway address as above.

Here's the example routing table configuration:

    config router static
        edit 1
            set dst 168.63.129.16 255.255.255.255
            set gateway 10.0.2.1
            set device "port2"
        next
        edit 2
            set dst 10.0.3.0 255.255.255.0
            set gateway 10.0.2.1
            set device "port2"
        next
    end


You can also configure a master/slave for configuration synchronization using the same mechanism used for Autoscale.  This will be identical on both FortiGates.  The 'master' will self-identify based on the fact that it's assigned IP for port2 is in the configuration.

    config system auto-scale
        set status enable
        set sync-interface "port2"
        set master-ip 10.0.2.5
    end



