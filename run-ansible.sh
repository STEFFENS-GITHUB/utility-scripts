if [ -z $1 ]; then
    echo "You must specify a playbook when you run the script"
    exit 5
fi

if [ -z $2 ]; then
    inventory=Inventory/inventory.yml
else
    inventory=$2
fi

ansible-playbook -i $inventory $1 --ask-vault-pass