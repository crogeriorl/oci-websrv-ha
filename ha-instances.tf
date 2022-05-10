
resource "oci_core_instance_configuration" "instance_config" {
    #Required
    compartment_id = var.compartment_ocid

    # defined_tags = {"Environm":"testes"}   erro!! Não tem tags definidas
    display_name = "instance-config-websrv"

    instance_details {
      #Required
      instance_type = "compute"
      
      launch_details {
          availability_domain = data.oci_identity_availability_domain.ad.name
          compartment_id      = var.compartment_ocid
          display_name        = var.hostname_label
          shape               = var.oci_vm_shape
          
          source_details {
            source_type = "image"
            image_id    = var.images[var.region]
          }

          create_vnic_details {
              subnet_id        = oci_core_subnet.subnet_publ.id
              assign_public_ip = true
              display_name     = "primaryvnic"
              hostname_label   = var.hostname_label
          }

          metadata = {
            ssh_authorized_keys = var.ssh_public_key
            user_data = filebase64("./deploy_nginx.sh")
          }

      }

    }

    source = "NONE"
}


resource "oci_core_instance_pool" "instance_pool" {
    #Required
    display_name = "instance-pool-websrv"
    compartment_id = var.compartment_ocid
    instance_configuration_id = oci_core_instance_configuration.instance_config.id
    size = var.conf_pool_size
    
    placement_configurations {
        #Required
        availability_domain = data.oci_identity_availability_domain.ad.name
        primary_subnet_id = oci_core_subnet.subnet_publ.id

        #Optional
        # fault_domains = var.instance_pool_placement_configurations_fault_domains
    }
    
    load_balancers {
        #Required
        backend_set_name = oci_load_balancer_backend_set.backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
        port = oci_load_balancer_backend_set.backend_set.health_checker[0].port
        vnic_selection = oci_core_instance_configuration.instance_config.instance_details[0].launch_details[0].create_vnic_details[0].display_name
    }
}
