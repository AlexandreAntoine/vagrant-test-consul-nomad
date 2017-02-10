# Name the region, if omitted, the default "global" region will be used.
region = "europe"

# Persist data to a location that will survive a machine reboot.
data_dir = "/var/nomad/"

# Bind to all addresses so that the Nomad agent is available both on loopback
# and externally.
bind_addr = "0.0.0.0"

advertise {
    http = "10.246.0.101:4646"
    rpc = "10.246.0.101:4647"
    serf = "10.246.0.101:4648"
}

# Enable debug endpoints.
enable_debug = true
