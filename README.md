# Azure Check Point Cloud Firewall as a Service Lab

This environment deploys a 100% Terraform-based Azure lab for testing Check Point Cloud Firewall as a Service inspection patterns:

- 3 client NETs (QA Dep, HR Dep and RnD Dep)
- 3 EC2 instances:
  - Linux bastion (public IP) in QA Dep VNET public subnet.
  - Linux1 (private IP) in QA Dep VNET and subnet.
  - Linux2 (private IP) in HR Dep VNET and subnet.
  - Linux3 (private IP) in RnD Dep VNET and subnet.

  ## Architecture Diagram

![AWS Check Point Centralized Inspection Architecture](./drawings/lab-azure-chkp-cfaas.drawio.png)

To edit this diagram, open [drawings/lab-azure-chkp-cfaas.drawio.png](./drawings/lab-azure-chkp-cfaas.drawio.png) with [diagrams.net](https://app.diagrams.net/) (File -> Open From -> GitHub).

