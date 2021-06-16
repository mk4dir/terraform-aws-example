data "aws_ami" "amazon-linux-2" {
owners = [ "amazon" ]
most_recent = true
 
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_instance" "assessment-ec2" {
    ami = "${data.aws_ami.amazon-linux-2.id}"
    instance_type = "t3.large"
    key_name = "kadir-bion"
    subnet_id = module.public_subnets.subnet_ids[0]
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.allow-ssh.id}"]
      
    tags = {
        Name = "assessment-ec2"
        Talent = "739343363997"
    }

    #user_data = "${file("./scripts/install-kubernetes.sh")}"

    depends_on = [
      module.public_subnets
    ]
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block           = var.vpc_cidr_block
  enable_dhcp_options  = var.enable_dhcp_options
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags              = var.tags
  tags_for_resource = var.tags_for_resource
}

module "public_subnets" {
  source = "./modules/public-subnets"

  vpc_id                  = module.vpc.vpc_id
  gateway_id              = module.vpc.internet_gateway_id
  propagating_vgws        = var.public_propagating_vgws
  map_public_ip_on_launch = var.map_public_ip_on_launch

  cidr_block         = var.public_cidr_block
  subnet_count       = var.public_subnet_count
  availability_zones = var.availability_zones

  tags              = var.tags
  tags_for_resource = var.tags_for_resource
}

module "nat_gateways" {
  source = "./modules/nat-gateways"

  subnet_count = "1" #module.public_subnets.subnet_count
  subnet_ids   = module.public_subnets.subnet_ids

  tags              = var.tags
  tags_for_resource = var.tags_for_resource
}

module "private_subnets" {
  source = "./modules/private-subnets"

  vpc_id            = module.vpc.vpc_id
  nat_gateway_count = "1" # module.nat_gateways.nat_gateway_count
  nat_gateway_ids   = module.nat_gateways.nat_gateway_ids
  propagating_vgws  = var.private_propagating_vgws

  cidr_block         = var.private_cidr_block
  subnet_count       = var.private_subnet_count
  availability_zones = var.availability_zones

  tags              = var.tags
  tags_for_resource = var.tags_for_resource
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow_ssh_connection"
  description = "Allow ssh connection"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress = {
    description = "value"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}