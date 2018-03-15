In order to configure session synchronization for this HA template, you must modify the load balance rules in the Azure load balancer.  Delete the existing rules (if they overlap with the port you want to use - port 80 in my example), and recreate them with "Floating IP (direct server return)" enabled.
For an explanation of how this works and some of the benefits, see Rule Type #2 here:
https://azure.microsoft.com/en-gb/documentation/articles/load-balancer-multivip-overview/

If you want to use port 443, you will first need to change the admin port settings (perhaps to port 8443) as below:

    config system global
      set admin sport 8443
    end

Once the new load balancer rules are in place with the floating IP, the load balancer will balance invisibly (that is it will forward the packets without changing the destination IP), so you will need to configure VIPs on the FortiGates for the public IPs:

    config firewall vip
      edit "AzurePIPexampleVIP"
        set extip 13.91.41.80  # <-- this should be the public IP address assigned to the load balancer
        set extintf "any"
        set portforward enable
        set mappedip "10.40.121.68" # <-- this should be the IP address of your target VM or service
        set extport 80
        set mappedport 80
      next
    end

To enable the PIP, create a firewall policy to match it:

    config firewall policy
      edit 0
        set srcintf "port1"
        set dstintf "port2"
        set srcaddr "all"
        set dstaddr "AzurePIPexampleVIP"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat enable
      next
    end

Finally, enable session synchronization:

    config system ha
      set session-pickup enable
      set session-pickup-connectionless enable
      set session-pickup-expectation enable
      set session-pickup-nat enable
      set override disable
    end

    config system session-sync
      edit 0
        set peerip 10.40.121.4 # <-- for FortiGate A, this should be the IP of FortiGate B
        set syncvd "root"
      next
    end

Note: If this is deployed to a single Virtual Network, for the return traffic to change in the event of the failure of FortiGate A, you will need a method to programatically modify the Azure User Defined Routing.  See the separate file titled HA-Monitoring for an example of this.  Also, don't forget to replicate this config on both FortiGates.

On the other hand, if you are deploying to multiple virtual networks (one for each security zone) with IPSec tunnels between those other VNets and each FortiGate, and using BGP to advertise routes, then you don't need to worry about user defined routing...
See here:
https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-bgp-overview/
