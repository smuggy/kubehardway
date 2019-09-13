output "master_instance_ids" {
    description = "list of instance ids"
    value       = "${aws_instance.kube-master.*.id}"
}

output "worker_instance_ids" {
    description = "list of instance ids"
    value       = "${aws_instance.kube-worker.*.id}"
}

output "master_user_data" {
    description = "list of names"
    value       = "${aws_instance.kube-master.*.user_data}"
}

output "worker_user_data" {
    description = "list of names"
    value       = "${aws_instance.kube-worker.*.user_data}"
}

output "master_ip_addresses" {
    description = "ip addresses"
    value = "${aws_instance.kube-master.*.private_ip}"
}

output "worker_ip_addresses" {
    description = "ip addresses"
    value = "${aws_instance.kube-worker.*.private_ip}"
}

#output "lb_https_dns" {
#    value = "${aws_lb.kube_https.*.dns_name}"
#}