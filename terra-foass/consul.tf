# Create an aws public instance with ubuntu and consul on it
resource "aws_instance" "public-consul-master-ubuntu" {
  count                       = 1
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  key_name                    = "${var.aws_key_name}"
  security_groups             = ["${data.aws_security_group.default.id}", "${aws_security_group.foaas_consul.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids      = ["${aws_security_group.foaas_consul.id}"]

  user_data = "${element(data.template_file.consul_server.*.rendered, count.index)}"

  tags {
    Name = "tf-foaas-public-consul-${count.index}"
    consul_server = "true"
  }

  depends_on = ["aws_subnet.private", "aws_subnet.public"]
}

//resource "aws_instance" "consul_client" {
//  count = "${var.clients}"
//
//  ami           = "${lookup(var.ami, var.aws_region)}"
//  instance_type = "t2.micro"
//  key_name      = "${var.aws_key_name}"
//  associate_public_ip_address = true
//
//  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
//  vpc_security_group_ids = ["${aws_security_group.foaas_consul.id}"]
//  subnet_id   = "${element(aws_subnet.public.*.id, count.index)}"
//
//  tags = {
//    Name = "foaas-consul-client-${count.index+1}"
//  }
//
//  user_data = "${element(data.template_file.consul_client.*.rendered, count.index)}"
//}

# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "foaas-consul-server-${count.index+1}",
     "server": true,
     "bootstrap_expect": ${var.servers},
     "ui": true,
     "client_addr": "0.0.0.0"
    EOF
  }
}

# Create the user-data for the Consul agent
data "template_file" "consul_client" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "foaas-consul-client-${count.index+1}",
     "enable_script_checks": true,
     "server": false
    EOF
  }
}



