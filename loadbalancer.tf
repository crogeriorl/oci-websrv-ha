
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
        url_path = "/"    # var.backend_set_health_checker_url_path
    }
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    name = "bkendset-websrv-ha"
    policy = "ROUND_ROBIN"

}


resource "oci_load_balancer_load_balancer" "load_balancer" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "lb-websrv-ha"
    shape = "flexible"    # = "lb-flexible-count"
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
    name = "lstnr-websrv-ha"
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
