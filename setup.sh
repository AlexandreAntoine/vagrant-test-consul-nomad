#! /bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <number of server> <number of client>"
    exit 1
fi

vagrant ssh server-node-01 -c "sudo nohup consul agent -config-dir /etc/consul.d/bootstrap/ & sleep 2"

for i in `seq 2 $1`;
do
vagrant ssh server-node-0$i -c "sudo start consul"
done

vagrant ssh server-node-01 -c "sudo killall consul || true"
sleep 2
vagrant ssh server-node-01 -c "sudo start consul"


for i in `seq 1 $2`;
do
    let firstClient="$1+$i"
    vagrant ssh server-node-0$firstClient -c "sudo start consul"
done

sleep 2

let srv_nbr="$1+$2"
let client_1="$1+1"
for i in `seq 1 $srv_nbr`;
do
     vagrant ssh server-node-0$i -c "sudo start nomad"
done
sleep 5
vagrant ssh server-node-01 -c "sudo consul members"
vagrant ssh server-node-01 -c "sudo nomad server-members"
vagrant ssh server-node-01 -c "sudo nomad node-status"
