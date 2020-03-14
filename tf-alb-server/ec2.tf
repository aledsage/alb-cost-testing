resource "aws_security_group" "server-sg" {
  name        = "webserver"
  description = "Web server with direct access"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  ingress {
    protocol    = "TCP"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["45.149.252.2/32", "5.148.153.61/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amazon-linux-2.image_id
  instance_type = "t3.medium"

  subnet_id     = aws_subnet.public.0.id
  associate_public_ip_address = true

  key_name = "alb-cost-testing"

  vpc_security_group_ids = [
    aws_security_group.server-sg.id
  ]

  credit_specification {
    cpu_credits = "unlimited"
  }

  user_data = <<-EOT
    #!/bin/bash
    sudo yum -y install httpd
    sudo amazon-linux-extras install -y php7.3

    # 129MB limit
    echo "SecRequestBodyLimit 135266304" >> /etc/modsecurity/modsecurity.conf
    echo "SecRequestBodyNoFilesLimit 135266304" >> /etc/modsecurity/modsecurity.conf

    sudo mkdir -p /var/www/html/files/
    sudo chown ec2-user /var/www/html/files/
    sudo chmod 755 /var/www/html/files/

    # For file upload
    echo "upload_max_filesize = 129M" >> /var/www/html/files/php.ini
    echo "post_max_size = 129M" >> /var/www/html/files/php.ini
    echo "file_uploads = On" >> /var/www/html/files/php.ini

    cat << EOF > /var/www/html/files/upload.php
    <?php
    $fileName = $_FILES['myfile']['name'];
    $fileSize = $_FILES['myfile']['size'];
    $fileTmpName  = $_FILES['myfile']['tmp_name'];
    $uploadPath = "/tmp/temp_file.tmp";

    $didUpload = move_uploaded_file($fileTmpName, $uploadPath);
    if ($didUpload) {
      echo "The file $fileName of size $fileSize has been uploaded";
    } else {
      echo "An error occurred uploading file: fileSize=$fileSize fileName=$fileName fileTmpName=$fileTmpName uploadPath=$uploadPath";
    }
    ?>
    EOF

    # Generate files for download
    echo "bdatfbrzq" > /var/www/html/files/10B
    dd if=/dev/urandom bs=1024 count=$[1] > /var/www/html/files/1KB
    dd if=/dev/urandom bs=1024 count=$[1024] > /var/www/html/files/1MB
    dd if=/dev/urandom bs=1024 count=$[1024*10] > /var/www/html/files/10MB
    dd if=/dev/urandom bs=1024 count=$[1024*128] > /var/www/html/files/128MB

    sudo systemctl start httpd

  EOT

  tags = {
    Name = "webserver-behind-alb"
  }
}
