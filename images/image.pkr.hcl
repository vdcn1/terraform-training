variable "region" {
  type    = string
  default = "us-east-2"
}

# keep AMI name unique
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "example" {
  ami_name      = "learn-terraform-packer-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-focal-20.04-*-server-*"
      architecture: "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.example"]

  provisioner "file" {
    source      = "../tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }

  # Put the exact path of the .aws credentials file here.
  provisioner "file" {
    source      = ".env"
    destination = "/tmp/credentials"
  }

  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}
