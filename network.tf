
resource "oci_core_virtual_network" "main_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "mainVCN"
  dns_label      = "mainvcn"
}

resource "oci_core_subnet" "subnet_publ" {
  cidr_block        = var.subnpubl_cidr
  display_name      = "Subnet_publ"
  dns_label         = "subnetpubl"
  security_list_ids = [oci_core_security_list.security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.main_vcn.id
  route_table_id    = oci_core_route_table.route_table.id
  dhcp_options_id   = oci_core_virtual_network.main_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "IGW"
  vcn_id         = oci_core_virtual_network.main_vcn.id
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.main_vcn.id
  display_name   = "route_table1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}
