provider "aws" {
  region = "us-east-1"
}

#Get a list of available zone in current region
data "aws_availability_zones" "all" {}

#Create Public subnet on the first available zone
resource "aws_subnet" "public_us_east_1" {
  vpc_id            = "vpc-00cc4a2a6875a2349"
  cidr_block        = var.subnet02_cidr
  availability_zone = data.aws_availability_zones.all.names[0]

  tags  = {
    name = "LSCP-PUBLIC-SUBNET-DEV-01"
  }
}

# Associate the Routetable to the Subnet
resource "aws_route_table_association" "my_vpc_ap_east_1a_public" {
  subnet_id  = aws_subnet.public_us_east_1.id
  route_table_id = "rtb-00a4d1a8a4666325d"
}

resource "aws_instance" "my_instance" {
  ami            = var.ami
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_security_group_ids = ["sg-02e8e738782c11c3c"]
  subnet_id      = aws_subnet.public_us_east_1.id
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.all.names[0]
  root_block_device {
    delete_on_termination = "true"
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }

  user_data      = <<-EOF
                   #!/bin/bash
                   sudo apt update
                   sudo apt -y install openjdk-17-jdk
                   sudo apt update
                   wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -P /tmp
                   sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt
                   sudo ln -s /opt/apache-maven-3.8.6 /opt/maven
                   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                   sudo apt update
                   sudo apt -y install unzip
                   sudo apt update
                   wget -c https://services.gradle.org/distributions/gradle-7.5-bin.zip -P /tmp
                   sudo unzip -d /opt/gradle /tmp/gradle-7.5-bin.zip
                   sudo apt-get -y update
                   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                   curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
                   echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
                   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                   sudo apt-get -y update
                   sudo apt -y install awscli
                   sudo apt-get -y update
                   sudo apt-get -y install docker.io
                   eksctl version
                   EOF


  tags  = {
    Name  = "AMI-IMAGE-INSTANCE"
  }
}

resource "aws_ami_from_instance" "example" {
  name               = "ami-lscp-env-terraform"
  source_instance_id = aws_instance.my_instance.id
  
  depends_on = [aws_instance.my_instance]
  
}

output "ami_id" {
  value = aws_ami_from_instance.example.id
}
