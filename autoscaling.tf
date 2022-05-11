resource "oci_autoscaling_auto_scaling_configuration" "auto_scaling_configuration" {
    #Required
    auto_scaling_resources {
        #Required
        id   = oci_core_instance_pool.instance_pool.id
        type = "instancepool"
    }
    compartment_id = var.compartment_ocid
    policies {
        #Required
        policy_type = "threshold"

        capacity {
            initial = var.conf_pool_size
            max     = var.max_pool_size
            min     = var.min_pool_size
        }
        display_name = "autoscaling_CPU_usage_policy"
        is_enabled   = "true"
        
        # Scaling Out
        rules {
            display_name = "scaleout_policy_rule"
            action {
                type = "SCALE_OUT"
                value = "1"
            }
            metric {
                metric_type = "cpu_utilization"
                threshold {
                    operator = "GT"     # Greater Than
                    value    = "70"     # percentage
                }
            }
        }

        # Scaling In
        rules {
            display_name = "scalein_policy_rule"
            action {
                type = "SCALE_IN"
                value = "-1"
            }
            metric {
                metric_type = "cpu_utilization"
                threshold {
                    operator = "LT"
                    value    = "30"
                }
            }
        }
    # policies
    }
    #Optional
    cool_down_in_seconds = "300"   # default
    display_name = "autoscaling_config1"
    is_enabled   = "true"
}