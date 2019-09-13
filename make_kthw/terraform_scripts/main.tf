provider "aws" {
    region = "us-east-1"
}

locals {
    mcount = 2
    master_hosts = "${formatlist("%s %s", aws_instance.kube-master.*.private_ip, aws_instance.kube-master.*.private_dns)}"
    worker_hosts = "${formatlist("%s %s", aws_instance.kube-worker.*.private_ip, aws_instance.kube-worker.*.private_dns)}"
    vpc_id       = "vpc-072a6961a84068faa"
    subnet_id    = "subnet-0a4c73185ec24de0c"
}

resource "aws_instance" "kube-master" {
# 18.04 LTS Bionic amd 64 hvm:ebs-ssd
    ami               = "ami-07d0cf3af28718ef8"
    instance_type     = "t3.large"
    availability_zone = "us-east-1a"
    count             = "${local.mcount}"

    key_name          = "mm-kube-management"
    subnet_id         = "${local.subnet_id}"
    vpc_security_group_ids = ["sg-050a675cd186a73a7"]
    user_data         = "mm-kube-master-${format("%02d", count.index)}"

    root_block_device {
        volume_size = "50"
    }

    provisioner "remote-exec" {
    	inline = [
	    "export PATH=$PATH:/usr/bin",
	    "sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq",
	    "sudo apt-get install -yq python3"
	]
        connection {
	    host = self.private_ip
            type = "ssh"
	    user = "ubuntu"
	    timeout = "2m"
	    private_key = "${file("/home/ubuntu/.ssh/mm-kube-management.pem")}"
        }
    }

    tags = {
        Name = "mm-kthw-master-${format("%02d", count.index)}"
	MyCommonTag = "mm-kthw"
        CostCenter = "308"
    }
}

resource "dns_a_record_set" "master_ingress" {
  zone = "theocc.com."
  name = "mm-kthw-mp"
  ttl  = 60
  addresses = "${aws_instance.kube-master.*.private_ip}"
}


resource "aws_instance" "kube-worker" {
# 18.04 LTS Bionic amd 64 hvm:ebs-ssd
    ami               = "ami-07d0cf3af28718ef8"
    instance_type     = "t3.large"
    availability_zone = "us-east-1a"
    count             = "3"

    key_name          = "mm-kube-management"
    subnet_id         = "${local.subnet_id}"
    vpc_security_group_ids = ["sg-050a675cd186a73a7"]
    user_data         = "mm-kube-worker-${format("%02d", count.index)}"

    root_block_device {
        volume_size = "50"
    }

    provisioner "remote-exec" {
    	inline = [
	    "export PATH=$PATH:/usr/bin",
	    "sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq",
	    "sudo apt-get install -yq python3"
	]
        connection {
	    host = self.private_ip
            type = "ssh"
	    user = "ubuntu"
	    timeout = "2m"
	    private_key = "${file("/home/ubuntu/.ssh/mm-kube-management.pem")}"
        }
    }

    tags = {
        Name = "mm-kthw-worker-${format("%02d", count.index)}"
	MyCommonTag = "mm-kthw"
        CostCenter = "308"
    }
}

data "template_file" "master_hosts" {
    template = "${file("${path.module}/templates/dev.cfg")}"
    depends_on = [aws_instance.kube-master, aws_instance.kube-worker]
    vars = {
	master_host_group = "${join("\n", local.master_hosts)}"
	worker_host_group = "${join("\n", local.worker_hosts)}"
    }
}

resource "null_resource" "dev-hosts" {
  triggers = {
    template_rendered = "${data.template_file.master_hosts.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.master_hosts.rendered}' > all_hosts"
  }
}
