// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0


provider "oci" {
  tenancy_ocid  = var.tenancy_ocid
  user_ocid 	  = var.user_ocid
  fingerprint 	= var.fingerprint
  private_key 	= var.private_key
  region 	      = var.region
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_region_mapping[var.region]
}

