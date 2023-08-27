module "ignition-vm" {
  source              = "../../module/ignition-vm"
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_user             = var.pm_user
  pm_password         = var.pm_password
  target_node         = "raisin"
  template_name       = "flatcar-production-qemu-3510.2.6"
  butane_conf         = "${path.module}/vm-configuration.bu.tftpl"
  name                = "flatcar-sample-container"
  vm_id               = 500
  network_tag         = 109
  tags                = ["sample", "flatcar"]
  vm_count            = 1
}
