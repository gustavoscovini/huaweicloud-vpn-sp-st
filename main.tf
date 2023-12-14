provider "huaweicloud" {
  region   = var.region[0]
  access_key = var.access_key
  secret_key = var.secret_key
  insecure   = true
}

#resources in SP
resource "huaweicloud_vpc" "vpc_sp" {
  name = var.vpc_name_sp
  cidr = var.vpc_cidr_sp
  region = var.region[0]
}

resource "huaweicloud_vpc_subnet" "subnet_sp" {
  name       = "subnet-testing-sp"
  cidr       = var.subnet_cidr_sp
  gateway_ip = var.subnet_gateway_sp
  vpc_id     = huaweicloud_vpc.vpc_sp.id
  region = var.region[0]
}

resource "huaweicloud_vpc_eip" "myeip1" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
  region = var.region[0]
}

resource "huaweicloud_vpc_eip" "myeip2" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test2"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
  region = var.region[0]
}

resource "huaweicloud_vpn_gateway" "gateway_sp" {
  name               = "gateway-sp"
  vpc_id             = huaweicloud_vpc.vpc_sp.id
  local_subnets      = [huaweicloud_vpc_subnet.subnet_sp.cidr]
  connect_subnet     = huaweicloud_vpc_subnet.subnet_sp.id
  availability_zones = [
    var.availability_zones_sp[0],
    var.availability_zones_sp[1]
  ]
  
  eip1 {
    id = huaweicloud_vpc_eip.myeip1.id
  }
  eip2 {
    id = huaweicloud_vpc_eip.myeip2.id
  }
  region = var.region[0]
}

resource "huaweicloud_vpn_customer_gateway" "cg-sp" {
  ip = huaweicloud_vpc_eip.myeip1-st.address
  name = "cg-sp"
  route_mode = "static"
  region = var.region[0]
}


#resources in ST


resource "huaweicloud_vpc" "vpc_st" {
  name = var.vpc_name_st
  cidr = var.vpc_cidr_st
  region = var.region[1]
}

resource "huaweicloud_vpc_subnet" "subnet_st" {
  name       = "subnet-testing-st"
  cidr       = var.subnet_cidr_st
  gateway_ip = var.subnet_gateway_st
  vpc_id     = huaweicloud_vpc.vpc_st.id
  region = var.region[1]
}

resource "huaweicloud_vpc_eip" "myeip1-st" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
  region = var.region[1]
}

resource "huaweicloud_vpc_eip" "myeip2-st" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "test2"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
  region = var.region[1]
}


resource "huaweicloud_vpn_gateway" "gateway_st" {
  name               = "gateway-st"
  vpc_id             = huaweicloud_vpc.vpc_st.id
  local_subnets      = [huaweicloud_vpc_subnet.subnet_st.cidr]
  connect_subnet     = huaweicloud_vpc_subnet.subnet_st.id
  availability_zones = [
    var.availability_zones_st[0]
  ]
  
  eip1 {
    id = huaweicloud_vpc_eip.myeip1-st.id  
    }
  eip2 {
    id = huaweicloud_vpc_eip.myeip2-st.id
  }
  region = var.region[1]
}

resource "huaweicloud_vpn_customer_gateway" "cg-st" {
  ip = huaweicloud_vpc_eip.myeip1.address
  name = "cg-st"
  route_mode = "static"
  region = var.region[1]
}


resource "huaweicloud_vpn_connection" "vpn-sp" {
  name = "VPN-SP"
  gateway_id = huaweicloud_vpn_gateway.gateway_sp.id
  gateway_ip = huaweicloud_vpc_eip.myeip1.id
  psk = var.default_password
  peer_subnets = [huaweicloud_vpc_subnet.subnet_st.cidr]
  vpn_type = "static"
  customer_gateway_id = huaweicloud_vpn_customer_gateway.cg-sp.id
  region = var.region[0]
}

resource "huaweicloud_vpn_connection" "vpn-st" {
  name = "VPN-ST"
  gateway_id = huaweicloud_vpn_gateway.gateway_st.id
  gateway_ip = huaweicloud_vpc_eip.myeip1-st.id
  psk = var.default_password
  peer_subnets = [huaweicloud_vpc_subnet.subnet_sp.cidr]
  vpn_type = "static"
  customer_gateway_id = huaweicloud_vpn_customer_gateway.cg-st.id
  region = var.region[1]
}

#ECS in São Paulo

data "huaweicloud_images_image" "ubuntu_sp" {
    name        = "Ubuntu 18.04 server 64bit"
    most_recent = true
}

data "huaweicloud_compute_flavors" "flavor_ecs_sp" {
  availability_zone = var.availability_zones_sp[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_networking_secgroup" "default_sg_sp" {
  name = "default"
}
resource "huaweicloud_compute_instance" "vm_1_sp" {
  name = "ecs-sp"
  image_id = data.huaweicloud_images_image.ubuntu_sp.id
  flavor_id = data.huaweicloud_compute_flavors.flavor_ecs_sp.flavors[0].id
  security_group_ids = [data.huaweicloud_networking_secgroup.default_sg_sp.id]
  admin_pass = var.default_password
  network {
    uuid = huaweicloud_vpc_subnet.subnet_sp.id 
    }
  region = var.region[0]
}

#ECS in Santiago
data "huaweicloud_images_image" "ubuntu_st" {
    name        = "Ubuntu 18.04 server 64bit"
    most_recent = true
    region = var.region[1]
}

data "huaweicloud_compute_flavors" "flavor_ecs_st" {
  availability_zone = var.availability_zones_st[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
  region = var.region[1]
}

data "huaweicloud_networking_secgroup" "default_sg_st" {
  name = "default"
  region = var.region[1]
}
resource "huaweicloud_compute_instance" "vm_1_st" {
  name = "ecs-st"
  image_id = data.huaweicloud_images_image.ubuntu_st.id
  flavor_id = data.huaweicloud_compute_flavors.flavor_ecs_st.flavors[0].id
  security_group_ids = [data.huaweicloud_networking_secgroup.default_sg_st.id]
  admin_pass = var.default_password
  network {
    uuid = huaweicloud_vpc_subnet.subnet_st.id 
    }
  region = var.region[1]
}