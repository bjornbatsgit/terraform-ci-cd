# Configure the Microsoft Azure Provider infield ICT
#see main.tf

variable "resource_group_name" {
  type        = string
  default     = "RG-infra-wijzijnjong"
  description = " resource group wij zijn jong"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" { # Create virtual network
  name     = var.resource_group_name
  location = "west europe"

  tags = {
    Environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "wzj-vnet-1"
  address_space       = ["10.1.0.0/16"]
  location            = "west europe"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

# Create subnet frontend
resource "azurerm_subnet" "myterraformsubnetfrontend" {
  name                 = "VNET-1-SN-Frontend"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefix       = "10.1.1.0/24"
}

# Create subnet backend
resource "azurerm_subnet" "myterraformsubnetbackend" {
  name                 = "VNET-1-SN-Backend"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefix       = "10.1.2.0/24"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "InfieldICTnsgtest" {
  name                = "NSG-SN-Backend"
  location            = "west europe"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

# Create Application Security Group and rule
resource "azurerm_application_security_group" "InfieldICTasgtest" {
  name                = "ASG-FEwebservers"
  location            = "west europe"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "InfieldICTnsgtest2" {
  name                = "NSG-SN-Frontend"
  location            = "west europe"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

#Create a key vault for disk encryption
resource "azurerm_key_vault" "InfieldICTkeyvault03" {
  name                        = "wzj-Keyvault03"
  location                    = "west europe"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  enabled_for_disk_encryption = true
  tenant_id                   = "148c1134-991e-465c-bdbe-aae05c8953bf"

  sku {
    name = "standard"
  }
}

# Create network interface for vm1
resource "azurerm_network_interface" "myterraformnic1" {
  name                      = "wzj-vm1-nic"
  location                  = "west europe"
  resource_group_name       = azurerm_resource_group.myterraformgroup.name
  network_security_group_id = azurerm_network_security_group.InfieldICTnsgtest2.id

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnetfrontend.id
    private_ip_address_allocation = "Dynamic"
    #    public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }
  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

# Create virtual machine vm1
resource "azurerm_virtual_machine" "myterraformvm1" {
  name                  = "wzj-vm1"
  location              = "west europe"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic1.id]
  vm_size               = "Standard_B2ms"

  storage_os_disk {
    name              = "OsDiskvm1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wzj-vm1"
    admin_username = "adminCPM"
    admin_password = "Passw0rd12345"
  }
  os_profile_windows_config {
  }

  tags = {
    environment     = "Production"
    ConsumedService = "Infrastructuur"
  }
}

# Create network interface for vm2
resource "azurerm_network_interface" "myterraformnic2" {
  name                      = "wzj-vm2-nic"
  location                  = "west europe"
  resource_group_name       = azurerm_resource_group.myterraformgroup.name
  network_security_group_id = azurerm_network_security_group.InfieldICTnsgtest2.id

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnetfrontend.id
    private_ip_address_allocation = "Dynamic"
    #       public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }
  tags = {
    environment     = "Ontwikkel"
    ConsumedService = "Infrastructuur"
  }
}

# Create virtual machine vm2
resource "azurerm_virtual_machine" "myterraformvm2" {
  name                  = "wzj-vm2"
  location              = "west europe"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic2.id]
  vm_size               = "Standard_B2ms"

  storage_os_disk {
    name              = "osdiskvm2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wzj-vm2"
    admin_username = "adminCPM"
    admin_password = "Passw0rd1234"
  }
  os_profile_windows_config {
  }

  tags = {
    environment     = "Ontwikkel"
    ConsumedService = "Infrastructuur"
  }
}

# Create network interface for vm3
resource "azurerm_network_interface" "myterraformnic3" {
  name                      = "wzj-vm3-nic"
  location                  = "west europe"
  resource_group_name       = azurerm_resource_group.myterraformgroup.name
  network_security_group_id = azurerm_network_security_group.InfieldICTnsgtest2.id

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnetfrontend.id
    private_ip_address_allocation = "Dynamic"
    #       public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }
  tags = {
    environment     = "Productie"
    ConsumedService = "Infrastructuur"
  }
}

# Create virtual machine vm3
resource "azurerm_virtual_machine" "myterraformvm3" {
  name                  = "wzj-vm3"
  location              = "west europe"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic3.id]
  vm_size               = "Standard_DS12_v2"

  storage_os_disk {
    name              = "osdiskvm3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name              = "wzj-vm3-datadisk"
    caching           = "ReadOnly"
    lun               = 0
    disk_size_gb      = 250
    create_option     = "empty"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name              = "wzj-vm3-datadisk2"
    caching           = "ReadOnly"
    lun               = 1
    disk_size_gb      = 65
    create_option     = "empty"
    managed_disk_type = "Premium_LRS"
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wzj-vm3"
    admin_username = "adminCPM"
    admin_password = "Passw0rd1234"
  }
  os_profile_windows_config {
  }

  tags = {
    environment     = "Productie"
    ConsumedService = "Infrastructuur"
  }
}

# Create network interface for vm4
resource "azurerm_network_interface" "myterraformnic4" {
  name                      = "wzj-vm4-nic"
  location                  = "west europe"
  resource_group_name       = azurerm_resource_group.myterraformgroup.name
  network_security_group_id = azurerm_network_security_group.InfieldICTnsgtest2.id

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnetfrontend.id
    private_ip_address_allocation = "Dynamic"
    #       public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }
  tags = {
    environment     = "Ontwikkel"
    ConsumedService = "Infrastructuur"
  }
}

# Create virtual machine vm4
resource "azurerm_virtual_machine" "myterraformvm4" {
  name                  = "wzj-vm4"
  location              = "west europe"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic4.id]
  vm_size               = "Standard_DS12_v2"

  storage_os_disk {
    name              = "osdiskvm4"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name              = "wzj-vm4-datadisk"
    caching           = "ReadOnly"
    lun               = 0
    disk_size_gb      = 250
    create_option     = "empty"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name              = "wzj-vm4-datadisk2"
    caching           = "ReadOnly"
    lun               = 1
    disk_size_gb      = 65
    create_option     = "empty"
    managed_disk_type = "Premium_LRS"
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wzj-vm4"
    admin_username = "adminCPM"
    admin_password = "Passw0rd1234"
  }
  os_profile_windows_config {
  }

  tags = {
    environment     = "Ontwikkel"
    ConsumedService = "Infrastructuur"
  }
}

