/*
Networking > outputs.tf
*/
output "vpc_id" {
  value = aws_vpc.myTF_vpc.id
}