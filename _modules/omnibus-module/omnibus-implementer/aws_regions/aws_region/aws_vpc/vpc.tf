# Set up just the VPC.
#
# This is mostly hard-coded, and mostly-open, for now.
#
# This currently supports:
# - The primary and secondary CIDR blocks
# - default security group
# - default network acl
# - default route table


# Resources:
# - https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.14.0/main.tf#L16-L18
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#cidr_block

locals {
  vpc_cidr_block        = jsondecode(var.aws_vpc_cfg)["vpc_cidr_block"]
  secondary_cidr_blocks = jsondecode(var.aws_vpc_cfg)["secondary_cidr_blocks"]

  ################################################################################
  # DHCP OPTIONS
  ################################################################################
  # In order to observer the difference after making changes to DHCP option sets, recreate the EC2 instances.
  #
  # OPTION A: No DHCP option set. Rely on AWS DNS resolution.
  #   This will support resolving AWS hosts such as "ip-10-100-102-138.ec2.internal"
  #   and general DNS (e.g. to resolve "wikipedia.com")
  enable_dhcp_options = false
  # These are not used (when enable_dhcp_options=false) but must be declared
  dhcp_options_domain_name         = ""
  dhcp_options_domain_name_servers = []
  #
  #
  # OPTION B: Mimic the default configuration which uses the AWS DNS service.
  # enable_dhcp_options = true
  # dhcp_options_domain_name = "ec2.internal"
  # dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
  #
  #
  # OPTION C: Use google DNS.
  #   This will not support resolving AWS hosts such as "ip-10-100-102-138.ec2.internal"
  # dhcp_options_domain_name = "*"
  # dhcp_options_domain_name_servers = ["8.8.8.8", "8.8.4.4"] # Google DNS servers
  #
  #
  # OPTION D: Tell servers to use localhost or a particular host for DNS resolution.
  #   This is a common setup when running a custom caching DNS solution
  #   e.g. via Consul's DNS service with local caching servers
  #   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options
  # enable_dhcp_options = true
  # dhcp_options_domain_name = "service.consul"
  # dhcp_options_domain_name_servers = ["127.0.0.1", "10.0.0.2"]
  #
  #
  # NTP
  #   dhcp_options_ntp_servers = [""]
  #
  #
  # NETBIOS (which is used by Windows servers)
  #   dhcp_options_netbios_name_servers = [""]
  #   dhcp_options_netbios_node_type = ""

  ################################################################################
  # DEFAULT ROUTE TABLE
  ################################################################################
  # https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.14.0/variables.tf#L410
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route
  #   Note that the default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
  #
  manage_default_route_table = true
  # Only include the "local" routes
  default_route_table_routes = []
  #
  # The public subnets have their own route tables that have this route in them.
  # default_route_table_routes = [
  #   { cidr_block = "0.0.0.0/0",
  #     gateway_id = aws_internet_gateway.this.id
  #   }
  # ]

  ################################################################################
  # DEFAULT NETWORK ACL
  ################################################################################
  manage_default_network_acl = true
  default_network_acl_ingress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]


}


################################################################################
# VPC
################################################################################

#   AWS Official docs for VPC
#     https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html
#   AWS Official Terraform (Ia) code for VPC
#     https://github.com/aws-ia/terraform-aws-vpc
#   Good Community VPC Module
#     https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#   Example of Terraform basic resource, in context of a good module
#     https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.14.0/main.tf#L20

# VPC DNS attributes
#   https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
#     enableDnsHostnames: Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses.
#     enableDnsSupport: Determines whether the VPC supports DNS resolution through the Amazon provided DNS server.

# Official AWS Resource (from Hashicorp AWS Provider)
#   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  # IPV4
  # Use RFC1918 addresses if you want to support (IPV4) hostnames (within this region)
  #
  # Hard-code IPV4 CIDR
  cidr_block = local.vpc_cidr_block
  # IPAM
  #   Get IPV4 CIDR from IPAM
  #     https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#ipv4_ipam_pool_id
  #ipv4_ipam_pool_id
  #     https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#ipv4_netmask_length
  #ipv4_netmask_length
  #
  # IPV6
  #
  # Auto-assign IPV6 cidr
  #   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#assign_generated_ipv6_cidr_block
  # assign_generated_ipv6_cidr_block = false  # Get a /56 block
  #
  # Restrict IPV6 IP advertisement
  #   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#ipv6_cidr_block_network_border_group
  #
  #   Get IPV6 CIDR from IPAM
  #     https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#ipv6_ipam_pool_id
  #ipv6_ipam_pool_id
  #     https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#ipv4_netmask_length
  #ipv6_netmask_length
  #

  # instance_tenancy"="dedicated" -> requires EC2 instances are "dedicated" and costs $2/hr ($17.5K/year)
  #   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#instance_tenancy
  instance_tenancy = "default"

  # VPC DNS Attribubutes
  #   https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
  #   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_support
  enable_dns_hostnames = "true" # Support Hostnames (ec2-internal
  enable_dns_support   = "true" # Use AWS DNS Servers

  # ClassicLink is Retired
  enable_classiclink             = "false"
  enable_classiclink_dns_support = "false"

  tags = local.tags

}

# This is useful for expanding a VPC if needed
# Additional CIDR blocks for the VPC
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count      = length(local.secondary_cidr_blocks) > 0 ? length(local.secondary_cidr_blocks) : 0
  vpc_id     = aws_vpc.this.id
  cidr_block = element(local.secondary_cidr_blocks, count.index)
}

# Default Security Groups
#   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
#     This is an advanced resource with special caveats. Please read this document in its entirety before using this resource. The aws_default_security_group resource behaves differently from normal resources. Terraform does not create this resource but instead attempts to "adopt" it into management.
#   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/default-custom-security-groups.html#creating-your-own-security-groups
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

################################################################################
# DHCP Options Set
#   https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html#AmazonDNS
################################################################################

# These are limited in various ways. Use aws_vpc_dhcp_options instead.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc_dhcp_options
#resource "aws_default_vpc_dhcp_options" "default" {
#  tags = {
#    Name = "Default DHCP Option Set for the region"
#  }
#}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc_dhcp_options
# https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.14.0/main.tf#L93
resource "aws_vpc_dhcp_options" "this" {
  count = local.enable_dhcp_options ? 1 : 0

  domain_name         = local.dhcp_options_domain_name
  domain_name_servers = local.dhcp_options_domain_name_servers
  #ntp_servers          = local.dhcp_options_ntp_servers
  #netbios_name_servers = local.dhcp_options_netbios_name_servers
  #netbios_node_type    = local.dhcp_options_netbios_node_type

  tags = local.tags
}


# Is this a bug? https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.14.0/main.tf#L112
resource "aws_vpc_dhcp_options_association" "this" {
  count = local.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Default Network ACLs
################################################################################

resource "aws_default_network_acl" "this" {
  count = local.manage_default_network_acl ? 1 : 0

  default_network_acl_id = aws_vpc.this.default_network_acl_id

  # subnet_ids is using lifecycle ignore_changes, so it is not necessary to list
  # any explicitly. See https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/736.
  subnet_ids = null

  dynamic "ingress" {
    for_each = local.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = local.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

################################################################################
# Default Route
################################################################################

resource "aws_default_route_table" "default" {
  count = local.manage_default_route_table ? 1 : 0

  default_route_table_id = aws_vpc.this.default_route_table_id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#propagating_vgws
  #propagating_vgws       = local.default_route_table_propagating_vgws

  dynamic "route" {
    for_each = local.default_route_table_routes
    content {
      # One of the following destinations must be provided
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
  }

  tags = local.tags
}
