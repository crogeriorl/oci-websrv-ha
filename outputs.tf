output "loadbalancer_state" {
  value = oci_load_balancer_load_balancer.load_balancer.state
}

output "loadbalancer_timecreated" {
  value = oci_load_balancer_load_balancer.load_balancer.time_created
}

output "loadbalancer_ip" {
  value = oci_load_balancer_load_balancer.load_balancer.ip_address_details
}