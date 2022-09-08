/*
Networking > main.tf
*/
/*=====================================================================*/
resource "random_integer" "random" {
  min = 11
  max = 99
}
/*=====================================================================*/
// This is used to get all the AZ from a paticular region.
data "aws_availability_zones" "available" {
}
/*=====================================================================*/
resource "aws_vpc" "myTF_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myTF_vpc_${random_integer.random.id}"
  }
  //We have used Lifecycle policy here because some resourses are depended on VPC.
  //For Example: If IGW is attached to a VPC, then we cannot add or Change the VPC.
  //In order to add or change the VPC, we use Lifecycle policy, create before destroy. 
  lifecycle {
    create_before_destroy = true
  }
}
/*=====================================================================*/
resource "aws_subnet" "myTF_private" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.myTF_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  // count.index is used below so we pull one AZ per index
  // used with data source data "aws_availability_zones" "available"{}
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "myTF_Private_${count.index + 1}"
  }
}
/*=====================================================================*/
resource "aws_subnet" "myTF_public" {
  count      = length(var.public_cidrs)
  vpc_id     = aws_vpc.myTF_vpc.id
  cidr_block = var.public_cidrs[count.index]
  // count.index is used below so we pull one AZ per index
  // used with data source data "aws_availability_zones" "available"{}
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "myTF_Public_${count.index + 1}"
  }
}
/*=====================================================================*/
resource "aws_internet_gateway" "myTF_internetgateway" {
  vpc_id = aws_vpc.myTF_vpc.id
  tags = {
    "Name" = "myTF_public_igw"
  }
}
/*=====================================================================*/
// Public RT
resource "aws_route_table" "myTF_rt" {
  vpc_id = aws_vpc.myTF_vpc.id
  tags = {
    "Name" = "myTF_public_rt"
  }
}
/*=====================================================================*/
// Associating Public Subnet with Public RT
resource "aws_route_table_association" "myTF_public_assoc" {
  count          = 1
  //The above count is used to tell the below statement how many public subnets to associate RT with.
  subnet_id      = aws_subnet.myTF_public.*.id[count.index]
  route_table_id = aws_route_table.myTF_rt.id
}
/*=====================================================================*/
// Main Route table (Private)
resource "aws_default_route_table" "myTF_private_rt" {
 // Every VPC gets a default RT and the below line simply specify that the 
 // default VPC RT will be this "aws_default_route_table" that we are creating.
  default_route_table_id = aws_vpc.myTF_vpc.default_route_table_id
  tags = {
    Name = "myTF_private_rt"
  }
}
/*=====================================================================*/
// Creating a Route to Internet(0.0.0.0/0) from IGW
resource "aws_route" "myTF_default_route" {
  route_table_id         = aws_route_table.myTF_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myTF_internetgateway.id
}
