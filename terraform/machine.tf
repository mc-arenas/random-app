resource "aws_instance" "machine01" {
  ami                         = "ami-0533f2ba8a1995cf9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg_acme.id]

  root_block_device {
    volume_size = 20 #20 Gb
  }

  tags = {
    Name        = "${var.author}.machine"
    Author      = var.author
    Date        = "2020.03.23"
    Environment = "LAB"
    Project     = "Random app"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/Escritorio/despliegue y operaciones/terraform/random-app/${var.key_path}")
  }

  provisioner "file" {
    content     = <<EOF
{
    "log-driver": "awslogs",
    "log-opts": {
      "awslogs-group": "docker-logs-test",
      "tag": "{{.Name}}/{{.ID}}"
    }
}
EOF
    destination = "/home/ec2-user/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y git",
      "sudo yum install -y docker httpd-tools",
      "sudo usermod -a -G docker ec2-user",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0-rc2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo chkconfig docker on",
      "sudo service docker start",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/mc-arenas/random-app.git",
      "cd random-app",
      "docker build -t mcarenas/random-app .",
      "docker run -d -p 80:5000 mcarenas/random-app",
      "portainer_passw=$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin ${var.portainer_passw} | cut -d ':' -f 2)",
      "docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer --admin-password $portainer_passw",
    ]
  }

}
