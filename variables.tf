variable "compartment_ocid" {}
variable "region" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key" {}
variable "ssh_public_key" {}


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
    us-phoenix-1  = "ocid1.image.oc1.phx.aaaaaaaacirjuulpw2vbdiogz3jtcw3cdd3u5iuangemxq5f5ajfox3aplxa"
    us-ashburn-1  = "ocid1.image.oc1.iad.aaaaaaaabbg2rypwy5pwnzinrutzjbrs3r35vqzwhfjui7yibmydzl7qgn6a"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaudio63gdicxwujhfok7jdyewf6iwl6sgcaqlyk4fvttg3bw6gbpq"
  }
}

variable "vcn_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnpubl_cidr" {
  default =  "10.0.11.0/24"
}

variable "oci_vm_shape" {
  default = "VM.Standard.E2.1.Micro"
}

variable "hostname_label" {
  default = "webserver"
}

# Auto Scaling metric type
variable asc_rules_metric_type {
  default = "CPU_UTILIZATION"
}

## Auto Scaling number of instances
variable "max_pool_size" {
  default = "2"
}

# to test load balancing, set all variables bellow to size 2.
variable "conf_pool_size" {
  default = "2"
}

variable "min_pool_size" {
  default = "1"
}