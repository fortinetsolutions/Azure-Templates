## This template set:
    Creates a FortiGate virtual appliance in an existing subnet, tied to existing HA deployment including:
    - Existing VNET
    - Existing Availability Set
    - Existing Public Load Balancer
    - Existing Internal Load Balancer

The beginning diagram should resemble the following:
---

![Example Diagram](https://raw.githubusercontent.com/fortinetclouddev/FortiGate-HA-for-Azure/SupplementExistingHA/diagram1.png)

---

Post deployment diagram will be modified to:
---

![Example Diagram](https://raw.githubusercontent.com/fortinetclouddev/FortiGate-HA-for-Azure/SupplementExistingHA/diagram2.png)

---

### Remaining Tasks:

This template does not configure the new FortiGate, nor does it configure the Public Load balancer beyond appending to the backend.  If you wish to provide administrative access, you will need to add all necessary configurations, including NAT rules and another public IP (if desired).



