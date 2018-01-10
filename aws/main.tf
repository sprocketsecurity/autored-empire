provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "autored"
  region = "us-east-2"
}

resource "aws_instance" "autored-empire" {
  ami           = "ami-82f4dae7"
  instance_type = "t2.micro"
  key_name      = "redteam"
  vpc_security_group_ids = ["${aws_security_group.autored-empire-sec-group.id}"]


  tags {
    Name = "autored-empire"
    Client = "${var.client_name}"
  }

  # upload our provisioning scripts
  provisioner "file" {
    source      = "${path.module}/../configs/"
    destination = "/tmp/"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.aws_priv_key}")}"
    }
  }

  # execute our provisioning scripts
  provisioner "remote-exec" {
    script = "${path.module}/../configs/empire_setup.bash"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.aws_priv_key}")}"
    }
  }

  # copy stager outputs to local host
  provisioner "local-exec" {
    command = "scp -i ${var.aws_priv_key} ubuntu@${aws_instance.autored-empire.public_ip}:Empire/stager-* output/"
  }

}


resource "aws_security_group" "autored-empire-sec-group" {
  name = "autored-empire-sec-group"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 25
    to_port = 25
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.autored-empire.public_ip}"
}

output "ssh_cmd" {
  value = "\nssh -i ${var.aws_priv_key} ubuntu@${aws_instance.autored-empire.public_ip}"
}

