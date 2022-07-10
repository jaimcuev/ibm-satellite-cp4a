data "ibm_is_security_group" "vpc_security_group" {
  name = ibm_is_vpc.vpc_vm.security_group[0].group_name
}

resource "ibm_is_security_group_rule" "outbound_tcp_3389_3389" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "outbound"
  tcp {
    port_min = 3389
    port_max = 3389
  }
}

resource "ibm_is_security_group_rule" "outbound_tcp_443_443" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "outbound"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "outbound_udp_30000_32767" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "outbound"
  udp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "outbound_tcp_30000_32767" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "outbound"
  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "outbound_tcp_80_80" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "outbound"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "inbound_tcp_22_22" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "inbound_icmp" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "inbound_udp_30000_32767" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  udp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "inbound_tcp_443_443" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "inbound_tcp_3389_3389" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  tcp {
    port_min = 3389
    port_max = 3389
  }
}

resource "ibm_is_security_group_rule" "inbound_tcp_30000_32767" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "inbound_tcp_80_80" {
  group = data.ibm_is_security_group.vpc_security_group.id
  direction = "inbound"
  tcp {
    port_min = 80
    port_max = 80
  }
}