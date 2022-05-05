// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0


variable "compartment_ocid" {}
variable "region" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key" {}
variable "ssh_public_key" {}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key = var.private_key
  region = var.region
}

variable "ad_region_mapping" {
  type = map(string)

  default = {
  #  us-phoenix-1 = 2
    us-ashburn-1 = 3
  #  sa-saopaulo-1 = 1
  }
}

variable "images" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.9-2020.10.26-0"
  #  us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaacirjuulpw2vbdiogz3jtcw3cdd3u5iuangemxq5f5ajfox3aplxa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaabbg2rypwy5pwnzinrutzjbrs3r35vqzwhfjui7yibmydzl7qgn6a"
  #  sa-saopaulo-1   = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaudio63gdicxwujhfok7jdyewf6iwl6sgcaqlyk4fvttg3bw6gbpq"
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_region_mapping[var.region]
}

resource "oci_core_virtual_network" "tcb_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "tcbVCN"
  dns_label      = "tcbvcn"
}

resource "oci_core_subnet" "tcb_subnet" {
  cidr_block        = "10.1.20.0/24"
  display_name      = "tcbSubnet"
  dns_label         = "tcbsubnet"
  security_list_ids = [oci_core_security_list.tcb_security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.tcb_vcn.id
  route_table_id    = oci_core_route_table.tcb_route_table.id
  dhcp_options_id   = oci_core_virtual_network.tcb_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "tcb_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "tcbIG"
  vcn_id         = oci_core_virtual_network.tcb_vcn.id
}

resource "oci_core_route_table" "tcb_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.tcb_vcn.id
  display_name   = "tcbRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tcb_internet_gateway.id
  }
}

resource "oci_core_security_list" "tcb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.tcb_vcn.id
  display_name   = "tcbSecurityList"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}


resource "oci_core_instance_configuration" "instance_config" {
    #Required
    compartment_id = var.compartment_ocid

    # defined_tags = {"Environm":"testes"}   erro!!
    display_name = "inst-config-tcb-wbsrv"

    instance_details {
      #Required
      instance_type = "compute"
      
      launch_details {
          availability_domain = data.oci_identity_availability_domain.ad.name
          compartment_id      = var.compartment_ocid
          display_name        = "webserver"
          shape               = "VM.Standard.E2.1.Micro"
          
          source_details {
            source_type = "image"
            image_id    = var.images[var.region]
          }

          create_vnic_details {
              subnet_id        = oci_core_subnet.tcb_subnet.id
              assign_public_ip = true
              display_name     = "vnic0"
              hostname_label   = "webserver"
          }

          metadata = {
            ssh_authorized_keys = var.ssh_public_key
            user_data = filebase64("./deploy_niture.sh")
          }

      }

    }

    source = "NONE"
}


resource "oci_core_instance_pool" "instance_pool" {
    #Required
    display_name = "inst-pool-ha-wbsrv"
    compartment_id = var.compartment_ocid
    instance_configuration_id = oci_core_instance_configuration.instance_config.id
    size = "2"
    
    placement_configurations {
        #Required
        availability_domain = data.oci_identity_availability_domain.ad.name
        primary_subnet_id = oci_core_subnet.tcb_subnet.id

        #Optional
        # fault_domains = var.instance_pool_placement_configurations_fault_domains
    }
    
    #Optional
    # defined_tags = {"Operations.CostCenter"= "42"}
    
    # freeform_tags = {"Department"= "Finance"}
    load_balancers {
        #Required
        backend_set_name = oci_load_balancer_backend_set.backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
        port = oci_load_balancer_backend_set.backend_set.health_checker[0].port
        vnic_selection = oci_core_instance_configuration.instance_config.instance_details[0].launch_details[0].create_vnic_details[0].display_name
    }
}


resource "oci_load_balancer_backend_set" "backend_set" {
    #Required
    health_checker {
        #Required
        protocol = "HTTP"

        #Optional
        # interval_ms = var.backend_set_health_checker_interval_ms
        port = "80"
        # response_body_regex = var.backend_set_health_checker_response_body_regex
        # retries = var.backend_set_health_checker_retries
        # return_code = var.backend_set_health_checker_return_code
        # timeout_in_millis = var.backend_set_health_checker_timeout_in_millis
        # url_path = var.backend_set_health_checker_url_path
    }
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    name = "backend-wbsrv-ha"
    policy = "ROUND_ROBIN"

}


resource "oci_load_balancer_load_balancer" "load_balancer" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "lb-wbsrv-ha"
    shape = "Flexible"    # = "10Mbps-Micro"
    subnet_ids = [oci_core_subnet.tcb_subnet.id]

    #Optional
    # defined_tags = {"Operations.CostCenter"= "42"}
    # freeform_tags = {"Department"= "Finance"}
    # ip_mode = "IPV4"
    is_private = "false"
    # network_security_group_ids = var.load_balancer_network_security_group_ids
    # reserved_ips {
        #Optional
        # id = var.load_balancer_reserved_ips_id
    # }
    shape_details {
      #Required
      maximum_bandwidth_in_mbps = "10"
      minimum_bandwidth_in_mbps = "10"
    }
}


resource "oci_load_balancer_listener" "listener" {
    #Required
    default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    name = "lstnr-wbsrv-ha"
    port = oci_core_instance_pool.instance_pool.load_balancers[0].port
    protocol = oci_load_balancer_backend_set.backend_set.health_checker[0].protocol

    #Optional
    connection_configuration {
        #Required
        idle_timeout_in_seconds = "60"

        #Optional
        # backend_tcp_proxy_protocol_version = var.listener_connection_configuration_backend_tcp_proxy_protocol_version
    }
    # hostname_names = [oci_load_balancer_hostname.test_hostname.name]
    # path_route_set_name = oci_load_balancer_path_route_set.test_path_route_set.name
    # routing_policy_name = oci_load_balancer_load_balancer_routing_policy.test_load_balancer_routing_policy.name
    # rule_set_names = [oci_load_balancer_rule_set.test_rule_set.name]

}
