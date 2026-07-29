########################
# VPC Peering
########################

resource "aws_vpc_peering_connection" "ram_main_mgmt" {
  vpc_id       = aws_vpc.ram_main.id
  peer_vpc_id  = aws_vpc.ram_mgmt.id
  auto_accept  = true

  tags = {
    Name = "ram-main-mgmt-peering"
  }
}

########################
# Routes for peering (main VPC)
########################

resource "aws_route" "ram_main_public_to_mgmt" {
  route_table_id            = aws_route_table.ram_main_public_rt.id
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ram_main_mgmt.id
}


########################
# Routes for peering (management VPC)
########################

resource "aws_route" "ram_mgmt_public_to_main" {
  route_table_id            = aws_route_table.ram_mgmt_public_rt.id
  destination_cidr_block    = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ram_main_mgmt.id
}
