resource "azurerm_resource_group" "rg1" {
    name = "TFRG"
    location = "eastus"
} 

resource "azurerm_virtual_network" "rg1vnet" {
    name                = "TFRG-VNET"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name
    address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "rg1subnet" {
    name                 = "TFRG-SUBNET"
    resource_group_name  = azurerm_resource_group.rg1.name
    virtual_network_name = azurerm_virtual_network.rg1vnet.name
    address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "rg1publicip" {
    name                = "TFRG-PUBLIC-IP"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name
    allocation_method   = "Static"
}

resource "azurerm_network_interface" "rg1nic" {
    name                = "TFRG-NIC"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name

    ip_configuration {
        name                          = "TFRG-NIC-IP"
        subnet_id                     = azurerm_subnet.rg1subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.rg1publicip.id
    }
}

resource "azurerm_network_security_group" "rg1nsg" {
    name                = "TFRG-NSG"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name

    security_rule {
        name                       = "Allow-RDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_virtual_machine" "rg1vm" {
    name                  = "rg1vm"
    location              = azurerm_resource_group.rg1.location
    resource_group_name   = azurerm_resource_group.rg1.name
    network_interface_ids = [azurerm_network_interface.rg1nic.id]
    vm_size               = "Standard_B1s"
    os_profile_windows_config {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
    }
    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
        version   = "latest"
    }

    os_profile {
        computer_name  = "TFRG-VM"
        admin_username = "adminuser"
        admin_password = "P@ssw0rd1234!"
    }
    # Remove os_profile_linux_config block for Windows VM
    }
    
