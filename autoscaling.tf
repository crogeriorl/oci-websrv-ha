resource "oci_autoscaling_auto_scaling_configuration" "auto_scaling_configuration" {
    #Required
    auto_scaling_resources {
        #Required
        id   = oci_core_instance_pool.instance_pool.id
        type = "instancePool"
    }
    compartment_id = var.compartment_ocid
    policies {
        display_name = "autoscaling-threshold-policy"
        is_enabled   = "true"
 
        capacity {
            initial = var.conf_pool_size
            max     = var.max_pool_size
            min     = var.min_pool_size
        }

        #Required
        policy_type = "threshold"
        
        # Scaling Out
        rules {
            display_name = "scaleout-policy-rule"
            action {
                type = "CHANGE_COUNT_BY"
                value = "1"
            }
            metric {
                metric_type = var.asc_rules_metric_type
                threshold {
                    operator = "GT"     # Greater Than
                    value    = "70"     # percentage
                }
            }
        }

        # Scaling In
        rules {
            display_name = "scalein-policy-rule"
            action {
                type = "CHANGE_COUNT_BY"
                value = "-1"
            }
            metric {
                metric_type = var.asc_rules_metric_type
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
    display_name = "autoscaling-config1"

    # Set "true" to enable Auto Scaling
    is_enabled   = "false"
}