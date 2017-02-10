datacenter = "virtualbox-dc"

client {
    enabled = true
    network_speed = 10
    network_interface = "eth1"
    options {
      "driver.raw_exec.enable" = "1"
    }
    meta {
    	 spark = true
    }
}

telemetry {
    statsite_address = "172.17.8.1:8125"
    publish_allocation_metrics = true
    publish_node_metrics = true
}
