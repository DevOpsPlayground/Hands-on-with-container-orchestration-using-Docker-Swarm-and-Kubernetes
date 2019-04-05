locals {
  module_source_base = "git@github.ecs-digital.co.uk/ECSD/playground-frame.git?ref=v2/"
  stack_name = "dpg-ldn-31"
  count = "1"
  ssh_key_name = "dpg-ldn-31-key"
  ssh_user = "playground"
	ssh_password = "RicknMortyS4"
  r53_zone_id = "ZKL6DCZ2ESZ63"

}
module "vpc" {
  source = "git::ssh://git@github.ecs-digital.co.uk/ECSD/playground-frame.git?ref=v2//modules/vpc"
	name = "${local.stack_name}-vpc"
}

module "animal" {
  source = "git::ssh://git@github.ecs-digital.co.uk/ECSD/playground-frame.git?ref=v2//modules/animal_names"
  count  = "${local.count}"
}

#### - This is to create a ${local.count} number of userdata templates that will be passed onto the linux_instances module
#### - Put the custom install bits into that file
data "template_file" "custom_install_script_linux" {
  count = "${local.count}"
  template = "${file("scripts/userdata.sh.tpl")}"

  vars {
    username = "${local.ssh_user}"
  }
}
####

module "linux_instances" {
  source                    = "git::ssh://git@github.ecs-digital.co.uk/ECSD/playground-frame.git?ref=v2//modules/linux_instance"
  count                     = "${local.count}"
  stack_name                = "${local.stack_name}"
  vpc_id                    = "${module.vpc.vpc_id}"
  subnet_ids                = "${module.vpc.public_subnets}"
  default_security_group_id = "${module.vpc.default_security_group_id}"
  animal_names              = "${module.animal.names}"
  ssh_key_name              = "${local.ssh_key_name}"
  ssh_user                  = "${local.ssh_user}"
  ssh_password              = "${local.ssh_password}"

  custom_install_scripts = "${data.template_file.custom_install_script_linux.*.rendered}"
}

module "dns" {
  source       = "git::ssh://git@github.ecs-digital.co.uk/ECSD/playground-frame.git?ref=v2//modules/dns"
  count        = "${local.count}"
  r53_zone_id  = "${local.r53_zone_id}"
  animal_names = "${module.animal.names}"
  ip_addresses = "${module.linux_instances.ip_addresses}"
}

output "ips" {
  value = "${module.dns.fqdns}"
}
output "ssh_user" {
  value = "${local.ssh_user}"
}
output "ssh_pw" {
  value = "${local.ssh_password}"
}

