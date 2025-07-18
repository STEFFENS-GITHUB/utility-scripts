# Checks if the user executing the script is root
if [ "$EUID" -ne 0 ]; then 
  echo "This script must be run as root"
  exit 1
fi

# Checks if you specified a ansible user to create, if not, creates ansible user named ansible
if [ -z $1 ]; then
    ANSIBLE_USER=ansible
else
    ANSIBLE_USER=$1
fi

# Checks if ansible user already exists, if not, creates it, generates keys, and adds it to sudoers
if id -u $ANSIBLE_USER &>/dev/null; then
    echo "Ansible user already exists...continuing"
else
    echo "Ansible user does not exist...creating"
    useradd -m -s /bin/bash $ANSIBLE_USER
    sudo -u $ANSIBLE_USER ssh-keygen -f /home/$ANSIBLE_USER/.ssh/id_rsa -N ""
    echo "Adding $ANSIBLE_USER to /etc/sudoers.d/$ANSIBLE_USER"; echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$ANSIBLE_USER > /dev/null
fi