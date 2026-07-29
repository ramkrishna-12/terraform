output "ram_main_vpc_id" {
  value = aws_vpc.ram_main.id
}

output "ram_mgmt_vpc_id" {
  value = aws_vpc.ram_mgmt.id
}

output "ram_main_public_subnets" {
  value = [
    aws_subnet.ram_main_public_a.id,
    aws_subnet.ram_main_public_b.id
  ]
}

output "ram_main_private_subnets" {
  value = [
    aws_subnet.ram_main_private_a.id,
    aws_subnet.ram_main_private_b.id
  ]
}

output "ram_mgmt_public_subnets" {
  value = [
    aws_subnet.ram_mgmt_public_a.id,
    aws_subnet.ram_mgmt_public_b.id
  ]
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.ram_main_mgmt.id
}
