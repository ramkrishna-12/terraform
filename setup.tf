# provider.tf 
provider "aws" {
    region = "us-west-1"
}
# main.tf 
resource "aws_vpc" "tf_demo_vpc" {
    cidr_block ="10.10.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name ="tf-demo-vpc"
    }
}

resource "aws_subnet" "tf_demo_vpc_pub" {
    vpc_id = aws_vpc.tf_demo_vpc.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "us-west-1a"
    map_public_ip_on_launch = true

    tags = {
        Name ="tf-demo-vpc-pub"
    }
}
# outputs.tf 
output "vpc_id" {
    value =aws_vpc.tf_demo_vpc.id
}
output "subnet_id" {
    value = aws_subnet.tf_demo_vpc_pub.id
}
