#####
#####
Deploy.sh Script usage:

Params list:

--ip="<IP>" Ip addres or adresses of servers to deploy software
--db-type="<redis|arangodb|all>" Service selector to install particular software type
--ssh-key-path="<key path>"/--ssh-pass="pass>" mutually exclusive params to use password or rsa key to connect.
--ssh-user="<usename>" Optional parameter you can use to set user to connect. If ommited your current username will be used.

***********************************************************
You should install yq and sshpass tools to use this script.
***********************************************************

####
This playbook installs next services:

- fail2ban to protect your ssh server from password bruteforcing if you chose SSH password usage.

- Redis Server if you enable it.

- ArangoDB3  Server if you enable it.

All the options you can set in roles/default/vars/main.yml

#####
Before usage you should set a few params.

1. Redis password and other options in redis.conf file ./roles/default/files/redis/redis.conf (requirepass string)

3. ArangoBD password and other options in roles/default/vars/main.yml

4. Databases to deploy in roles/default/vars/main.yml

5. If you want to use SSH password auth or not in roles/default/vars/main.yml

6. List of DB servers you want to deploy software and configs onto. in ./inventory

7. User which you want to use to connect to DB servers in ./deploy.yaml
#####
To Start deployment process use:

ansible-playbook deploy.yml -i inventory

################## Roles

default - default user creation and software install

##################
files/ - static configs
vars/ - dynamic configs data and playbook configs
templates/ - rules for dynamic config generation
##################
