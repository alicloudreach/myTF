/*=====================================================================*/
resource "aws_security_group" "myTF_public_sg" {
  name = "myTF_public_sg"
  description = "Security Group for Public Access"
  vpc_id = aws_vpc.myTF_vpc.id
  ingress  {
    cidr_blocks = [var.access_ip]
    description = "ssh access"
    from_port = 22
    protocol = "tcp"
    to_port = 22
  } 
  ingress  {
    cidr_blocks = [var.access_ip]
    description = "HTTP access"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  } 

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}
/*=====================================================================*/
resource "aws_security_group" "myTF_private_sg" {
    name = "myTF_private_sg"
    description = "Security Group for resources in Private Subnet"
    vpc_id = aws_vpc.myTF_vpc.id
    lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

/*resource "aws_security_group_rule" "ssh_ingress_access" {
  description = "RDS access"
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.myTF_private_sg.id
  cidr_blocks = [var.vpc_cidr]
}*/


//I am commenting this to see stateful functionality of the Security group
/*resource "aws_security_group_rule" "rds_egress_access" {
  description = "RDS access"
  type = "egress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.myTF_private_sg.id
  cidr_blocks = [var.vpc_cidr]
}*/

resource "aws_security_group_rule" "All_egress_access" {
  description = "All traffic access"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "All"
  security_group_id = aws_security_group.myTF_private_sg.id
  cidr_blocks = [var.vpc_cidr]
}