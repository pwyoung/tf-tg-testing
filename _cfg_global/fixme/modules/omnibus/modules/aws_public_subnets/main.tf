################################################################################
# Internet Gateway
################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
# https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-igw-ngw.html
resource "aws_internet_gateway" "this" {
  # This is SUPPOSEDLY optional.
  # SUPPOSEDLY can use aws_internet_gateway_attachment too, but that resource is
  # not supported in Terraform (at least with the provider/version used here)
  vpc_id = var.vpc_id

  tags = var.tags
}
# An advantage of using the attachment WOULD BE that we could add/remove internet access
# by removing the attachment.
# Routing and EC2 instances would still be associated with the IGW
#resource "aws_internet_gateway_attachment" "this" {
#  internet_gateway_id = aws_internet_gateway.this.id
#  vpc_id = var.vpc_id
#}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags   = var.tags
}

################################################################################
# Publiс route table and IGW
################################################################################

# Local routes (for the subnet CIDR to route to the local interfaces) are automatically added
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags   = var.tags
  # DO NOT INCLUDE IN-LINE ROUTES IN THE ROUTE TABLE
  # Per https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#gateway_id
  gateway_id = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

################################################################################
# Public subnets
################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id = var.vpc_id

  cidr_block = element(concat(var.public_subnet_cidrs, [""]), count.index)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#availability_zone
  availability_zone = element(var.azs, count.index)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#map_public_ip_on_launch
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

################################################################################
# Public Subnet Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  vpc_id = var.vpc_id

  subnet_ids = aws_subnet.public[*].id

  tags = var.tags
}

resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

