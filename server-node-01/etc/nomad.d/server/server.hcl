datacenter = "virtualbox-dc"

server {
    enabled = true
    bootstrap_expect = 1
}

telemetry {
    statsite_address = "172.17.8.1:8125"
    publish_allocation_metrics = true
    publish_node_metrics = true
}
