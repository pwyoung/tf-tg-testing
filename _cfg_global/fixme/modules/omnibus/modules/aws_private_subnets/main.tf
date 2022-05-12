# DOCS:
# - This creates subnets that are behind a NAT GATEWAY to prevent external hosts
#   initiating connections to them.
# - The NAT GATEWAY is "public", to allow the hosts to connect to the internet
# - This creates one "public" NAT Gateway per private subnet.
#   Each "public" NAT Gateway must be in a public subnet, for routing to its IGW.

################################################################################
# NAT Gateway
################################################################################
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
#
# TODO: consider adding examples/support for routing to other VPCs or on-prem network

resource "aws_nat_gateway" "public" {
  count = length(var.private_subnet_cidrs)

  tags = var.tags

  # PUBLIC NAT GATEWAY
  #   A "public" NAT GATEWAY exists in a public subnet so that traffic can be routed
  #   from a private subnet through it to an IGW
  connectivity_type = "public"
  subnet_id         = var.public_subnet_ids[count.index]     # This must be a public subnet (since traffic will be routed to the IGW)
  allocation_id     = aws_eip.nat_gateway_ip[count.index].id # This is the IP of the traffic sent from the NAT

  # PRIVATE NAT GATEWAY
  #   A "private" NAT GATEWAY is labelled as such in order to prevent routing traffic through an IGW.
  #   Even if a route table directs traffic to an IGW, the traffic will not be routed through the IGW.
  #   https://aws.amazon.com/about-aws/whats-new/2021/06/aws-removes-nat-gateways-dependence-on-internet-gateway-for-private-communications/
  #connectivity_type = "private"
  #subnet_id = [count.index] # This can be in a private subnet since it will not route to an IGW
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "nat_gateway_ip" {
  count = length(var.private_subnet_cidrs)

  tags = var.tags

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip#public_ipv4_pool
  public_ipv4_pool = "amazon"
  vpc              = "true"

}

################################################################################
# Private route table
################################################################################

# Local routes (for the subnet CIDR to route to the local interfaces) are automatically added
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = var.vpc_id
  tags   = var.tags
  # DO NOT INCLUDE IN-LINE ROUTES IN THE ROUTE TABLE
  # Per https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
}

resource "aws_route" "nat_gateway" {
  count = length(var.private_subnet_cidrs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#nat_gateway_id
  nat_gateway_id = aws_nat_gateway.public[count.index].id

  timeouts {
    create = "5m"
  }
}

# resource "aws_route" "nat_gateway_ipv6" {
#   count = length(var.private_subnet_cidrs)
#
#   route_table_id = aws_route_table.private[count.index].id
#   destination_ipv6_cidr_block = "::/0"
#
#   # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#nat_gateway_id
#   nat_gateway_id = aws_nat_gateway.public[count.index].id
# }

################################################################################
# Private subnets
################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = var.vpc_id

  cidr_block = element(concat(var.private_subnet_cidrs, [""]), count.index)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#availability_zone
  availability_zone = element(var.azs, count.index)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#map_private_ip_on_launch
  map_public_ip_on_launch = false # Be explicit about this

  tags = var.tags
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index) #aws_route_table.private.id
}

################################################################################
# Private Subnet Network ACLs
################################################################################

resource "aws_network_acl" "private" {
  vpc_id = var.vpc_id

  subnet_ids = aws_subnet.private[*].id

  tags = var.tags
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}
