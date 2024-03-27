
#!/bin/bash

if [ $1 = "install" ]; then
    echo "Mise à jour des dépôts et installation du paquet nginx..."
   sudo  apt update
   sudo  apt install -y nginx
    exit 0
fi
install=$1

if [ $# -ne 3 ]; then
    echo "Usage: $0 <user> <username> <password> "
    exit 1
fi

user=$1
username=$2
password=$3

useradd -m $username
echo "$username:$password" | sudo chpasswd

echo "Utilisateur $username créé avec succès."
echo "Nom d'utilisateur: $username"
echo "Mot de passe : $password"
