$ docker network create -d macvlan \
  --subnet=192.168.233.0/24 \
  --gateway=192.168.233.1 \
  -o parent=eth0 \
  macvlan-net