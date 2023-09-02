env_details = {
   subscription_id = "e4b7dd8e-bfe7-4755-a866-36c905ba5699"
   hd_location   = "southindia"
   tag = "hd"
}

vnet_details ={
   vnet_rg_name = "hd-vnet-rg"
   vnet_name = "hd-vnet"
   vnet_cidr = ["192.168.0.0/16"]
   subnet_name = "hd-subnet"
   subnet_cidr = ["192.168.255.224/27"]
}

vm_details = {
   vm_rg_name = "hd-vm-rg"
   vm_nodes_name = ["cp", "node-1"]
   vm_image_info = {
     publisher = "Canonical"
     sku = "22_04-LTS"
     offer = "0001-com-ubuntu-server-jammy"
     version = "22.04.202306010"
   }
   vm_storage_info = {
     managed_disk_type = "Standard_LRS"
   }
}
