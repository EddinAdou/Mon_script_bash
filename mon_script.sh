#!/bin/bash

configure_site() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Erreur : veuillez spécifier un nom pour le site à configurer et le port HTTP."
    return 1
  fi

  config_file="/etc/nginx/sites-available/$1"
  web_root="/var/www/$1"

  if [ -e "$config_file" ]; then
    echo "Erreur : un fichier de configuration pour $1 existe déjà."
    return 1
  fi

  if [ -d "$web_root" ]; then
    echo "Erreur : le répertoire $web_root existe déjà."
    return 1
  fi

  mkdir -p "$web_root"
  echo "<html><head><title>$1</title></head><body><h1>$1</h1></body></html>" > "$web_root/index.html"

  cp /etc/nginx/sites-available/default "$config_file"

  sed -i "s/server_name _;/server_name $1;/" "$config_file"
  sed -i "s/listen 80 default_server;*/listen $2 default_server; listen [::]:$2 default_server;/" "$config_file"
  sed -i "s#root /var/www/html;#root $web_root;#" "$config_file"

  echo "Fichier de configuration créé pour $1 sur le port $2."
  echo "Répertoire $web_root créé avec le fichier index.html."

}
active_site() {
  if [ -z "$1" ]; then
    echo "Erreur : veuillez entrer un nom de site à activer."
    return 1
  fi

  config_file="/etc/nginx/sites-available/$1"

  if [ ! -e "$config_file" ]; then
    echo "Erreur : aucun fichier de configuration pour $1 n'a été trouvé."
    return 1
  fi

  nginx -t -c "$config_file" >/dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Erreur : la syntaxe du fichier de configuration est invalide."
    return 1
  fi

  ln -s "$config_file" "/etc/nginx/sites-enabled/$1"
  systemctl reload nginx

  echo "La configuration de $1 a été activée et le service Nginx a été rechargé."
}

if [ $1 = "install" ]; then
    echo "Mise à jour des dépôts et installation du paquet nginx..."
    apt update
    apt install -y nginx
    exit 0
fi

if [ $1 = "configure_site" ] && [ $# -eq 3 ]; then
    configure_site $2 $3
    exit 0
fi

if [ $# -ne 3 ]; then
    echo "Usage: $0 <user|configure_site> <username|site_name> <password|http_port>"
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

