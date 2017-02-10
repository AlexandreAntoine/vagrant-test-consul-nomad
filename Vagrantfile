# -*- mode: ruby -*-
# # vi: set ft=ruby :

$all_docker_install = true
$server_num_instances = 1
$client_num_instances = 2
$enable_serial_logging = false
$forwarded_ports = {}
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 2
$vb_cpuexecutioncap = 100
$shared_folders = {}


$scriptDocker = <<SCRIPTDOCKER

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get update
sudo apt-get install -y docker-engine

SCRIPTDOCKER

$script = <<SCRIPT

sudo echo "export private_ipv4=$1" >> /etc/environment
sudo export private_ipv4=$1


echo Installing dependencies...
sudo apt-get update
sudo apt-get install -y unzip curl

echo Fetching Consul...
cd /tmp/
curl https://releases.hashicorp.com/consul/0.7.4/consul_0.7.4_linux_amd64.zip -o consul.zip  > /dev/null

echo Installing Consul...
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul


echo Fetching Nomad...
curl https://releases.hashicorp.com/nomad/0.5.4/nomad_0.5.4_linux_amd64.zip -o nomad.zip > /dev/null

echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad

sudo mkdir /var/consul/
sudo mkdir /var/nomad/

sudo cp /tmp/consul.conf /etc/init/consul.conf
sudo cp /tmp/nomad.conf /etc/init/nomad.conf

find /etc/consul.d -type f -print0 | xargs -0 sed -i "s/X\.X\.X\.X/$1/g"
find /etc/nomad.d -type f -print0 | xargs -0 sed -i "s/X\.X\.X\.X/$1/g"

SCRIPT


# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  (1..$server_num_instances+$client_num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % ["server-node", i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
      end

      ip = "10.246.0.#{i+100}"
      config.vm.network :private_network, ip: ip

      if File.exist?("server-node-%02d/" % i) and (i <= $server_num_instances)
        config.vm.synced_folder "server-node-%02d/etc/consul.d/" % i, "/etc/consul.d/"
        config.vm.synced_folder "server-node-%02d/etc/nomad.d/" % i, "/etc/nomad.d/"
	config.vm.provision "file", source: "server-node-%02d/etc/init/consul.conf" % i, destination: "/tmp/consul.conf"
	config.vm.provision "file", source: "server-node-%02d/etc/init/nomad.conf" % i, destination: "/tmp/nomad.conf"
      end

      if ($all_docker_install or i > $server_num_instances)
	 config.vm.provision "shell", inline: $scriptDocker
      end
      if (i > $server_num_instances)
         config.vm.synced_folder "client-node/etc/nomad.d/", "/etc/nomad.d/"
         config.vm.provision "file", source: "client-node/etc/init/consul.conf", destination: "/tmp/consul.conf"
         config.vm.provision "file", source: "client-node/etc/init/nomad.conf", destination: "/tmp/nomad.conf"
      	 config.vm.provision "file", source: "client-node/etc/consul.d/client/config.json", destination: "/tmp/config.json"
	 config.vm.provision "shell", inline: "sudo mkdir -p /etc/consul.d/client"
	 config.vm.provision "shell", inline: "sudo cp /tmp/config.json /etc/consul.d/client/config.json"
      end

      if (i == $server_num_instances + 1)
      	 config.vm.provision "file", source: "client-node/etc/consul.d/client/config-ui.json", destination: "/tmp/config.json"
	 config.vm.provision "shell", inline: "sudo cp /tmp/config.json /etc/consul.d/client/config.json"
      	 config.vm.provision "file", source: "client-node/etc/consul.d/client/consul-ui.json", destination: "/tmp/consul-ui.json"
	 config.vm.provision "shell", inline: "sudo cp /tmp/consul-ui.json /etc/consul.d/client/consul-ui.json"
      end

      config.vm.provision "shell", inline: $script, args: [ip]
    end  
  end
end
