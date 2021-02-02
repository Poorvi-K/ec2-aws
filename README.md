Project is about creating an EC2 instance in custom VPC for an hypothetical application "knew" by leveraging the concept of IAC.
Infrastructure has been created by using human readable Hashicorp Language.

Following steps has been followed:
1. Create VPC
2. Create an Internet Gateway
3. Associate Internet Gateway with VPC
4. Create subnet with in VPC
5. Create Route Tables
6. Associate route tables with subnet
7. Create security group(ingress/egress)
8. Create Elastic ip
9. Create an EC2 instance within the subnet and associate the security group and elastic ip

 