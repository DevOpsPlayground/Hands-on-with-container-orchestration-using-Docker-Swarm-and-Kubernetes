provider "aws" {}

### - This is to create a SSH Keypair for the admin user
resource "tls_private_key" "ssh_keypair" {
  count     = 1
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${local.ssh_key_name}"
  public_key = "${tls_private_key.ssh_keypair.public_key_openssh}"

  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh_keypair.private_key_pem}\" > ${local.ssh_key_name}.pem && chmod 400 ${local.ssh_key_name}.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f ${local.ssh_key_name}.pem"
  }
}
###