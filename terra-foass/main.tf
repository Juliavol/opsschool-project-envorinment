#Create two VPCs (private and public) - remember to update the security group not to allow all traffic everywhere
# Setup the region in which to work.
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC
resource "aws_vpc" "foaas-VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "tf-cluster-foass"
  }
}

# Grab the list of availability zones
data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.foaas-VPC.id}"

  tags {
    Name = "tf-cluster-1-main-gw"
  }
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "foaas-consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}

resource "aws_iam_role" "jenkins-ec2-full" {
  name               = "foaas-jenkins-ec2-full"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}
# Create an IAM policy
resource "aws_iam_policy" "consul-join" {
  name        = "foaas-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

# Create an IAM policy
resource "aws_iam_policy" "jenkins-ec2-dynamic-slaves" {
  name        = "foaas-jenkins-ec2-dynamic-slaves"
  description = "Allows Jenkins nodes to create dynamic slaves"
  policy      = "${file("${path.module}/templates/policies/ec2-full-access.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "jenkins-ec2-dynamic-slaves" {
  name       = "foaas-jenkins-ec2-dynamic-slaves"
  roles      = ["${aws_iam_role.jenkins-ec2-full.name}"]
  policy_arn = "${aws_iam_policy.jenkins-ec2-dynamic-slaves.arn}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "foaas-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "foaas-consul-join"
  role = "${aws_iam_role.consul-join.name}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "foaas-jenkins-ec2-dynamic-slaves" {
  name  = "foaas-jenkins-ec2-dynamic-slaves"
  role = "${aws_iam_role.jenkins-ec2-full.name}"
}




