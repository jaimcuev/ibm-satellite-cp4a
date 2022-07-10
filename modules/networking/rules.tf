resource "ibm_is_security_group_rule" "sg-rule-inbound-ssh" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-http" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-https" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-api" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-api2" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  udp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-icmp" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "sg-rule-outbound" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1
    port_max = 65535
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-from-the-group" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = ibm_is_vpc.vpc.default_security_group
}

resource "ibm_is_security_group_rule" "sg-rule-outbound-to-the-group" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = ibm_is_vpc.vpc.default_security_group
}