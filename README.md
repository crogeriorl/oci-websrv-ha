Simple project to deploy a H.A. webserver pool with load balancing and auto-healing (limited in 2 machines for OCI's always free tier) on the Oracle Cloud Infrastructure (OCI)

The environment is deployed with Terraform / Terraform Cloud and bash shell scripts wich was tested on Oracle Linux 7.9 virtual machines.

The credentials and secrets for login authentication and authorization in OCI - variables listed in variables.tf file with empty { } - must be setting in the Terraform Cloud project workspace (Terraform Variables).

No more than 5 minutes to get up your web application or web site with high availability, self-healing and load balanced, all them free in the OCI.