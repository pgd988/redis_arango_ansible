#!/bin/bash

echo -e "\nTo use the 'ssh' connection type with passwords, you must install the sshpass program\n"
echo -e "\nPlease install yq to use this script (snap install yq)\n"

print_help () {
    echo -e "\nPlease call '$0 --ip=\"<IP IP2 IP3 IP4 etc.>\" --db-type=\"<redis|arangodb|all>\" --ssh-key-path=\"<key path>\"/--ssh-pass=\"pass>\" (optional --ssh-user=\"<usename>\") to run this!\n"
}

if [ -z "$1" ]; then
    print_help
    exit 1
fi

### Args parcing
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            --ip)              IP=${VALUE} ;;
            --db-type)    DB_TYPE=${VALUE} ;;
            --ssh-key-path)    SSH_KEY=${VALUE} ;;
            --ssh-pass)    SSH_PASS=${VALUE} ;;
            --ssh-user)    SSH_USER=${VALUE} ;;
            *)
    esac
done

### Args Checks
for i in $IP;do
if  [[ ! $i =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Bad IP addr!"
    print_help
    exit 1
fi
done

if [[ ! $DB_TYPE =~ (redis|arangodb|all) ]]; then
    echo "Bad DB name!"
    print_help
    exit 1
fi

if [ -z "$SSH_KEY" ] && [ -z "$SSH_PASS" ] ; then
    echo "We need some credentials to connect!"
    print_help
    exit 1
fi

if [ -z "$SSH_USER" ]; then
    SSH_USER=$USER
fi

if [[ ! -z "$SSH_KEY" ]] && [[ ! -z "$SSH_PASS" ]] ; then
    echo "You have to use one auth type Only!"
    print_help
    exit 1
fi

### Args transform
if [[ $DB_TYPE == all ]]; then
    yq w -i ./roles/default/vars/main.yaml redis_server.enabled true && yq w -i ./roles/default/vars/main.yaml redis_server.enabled true
elif [[ $DB_TYPE == redis ]]; then
    yq w -i ./roles/default/vars/main.yaml redis_server.enabled true && yq w -i ./roles/default/vars/main.yaml redis_server.enabled false
elif [[ $DB_TYPE == arangodb ]]; then
    yq w -i ./roles/default/vars/main.yaml redis_server.enabled false && yq w -i ./roles/default/vars/main.yaml redis_server.enabled true
fi
if [[ ! -z "$SSH_PASS" ]]; then
    echo "[db_servers]" > ./inventory
for i in $IP; do
    sed -i "/\[db_servers\]/a $i ansible_user=$SSH_USER ansible_password=$SSH_PASS" ./inventory
done
ansible-playbook deploy.yaml -i inventory -u $SSH_USER
fi
echo "[db_servers]" > ./inventory
for i in $IP; do
    sed -i "/\[db_servers\]/a $i ansible_user=$SSH_USER" ./inventory
done
ansible-playbook deploy.yaml -i inventory -u $SSH_USER -b --private-key=$SSH_KEY
