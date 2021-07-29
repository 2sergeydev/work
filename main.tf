provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}
resource "aws_instance" "Ubuntu" {
  count                       = 1
  ami                         = "ami-0747bdcabd34c712a"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-d5d136ce"]
  associate_public_ip_address = "true"
  key_name                    = "newkey1"
  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update",
      "sudo apt install -y openjdk-8-jdk",
      "sudo apt install -y maven -y",
      "sudo apt install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
    ]
  }
connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("newkey1.pem")
  }
  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}
