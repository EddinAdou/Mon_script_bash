#!/bin/bash

if [ "$#" -lt 1 ] || ([ "$1" != "user" ] && [  "$1" != "install" ] && [ "$1" != "configure_site" ] && [ "$1" != "active_site" ] && [ "$1" != "add_cronjob" ]); then
        echo "Usage: $0 user <username> <password> or $0 install or $0 configure_site <site_name> <http_port> or $0 active_site <site_name> or $0 add_cronjob <file_name>"
        exit 1
fi

create_user() {
        if id -u "$1" >/dev/null 2>&1; then
                echo "L'utilisateur '$1' existe deja,"
                return 1
        fi
        useradd -m -s /bin/bash "$1"
        if [ "$?" -ne 0 ]; then
                echo "Impossible de créer l'utilisateur '$1'."
                return 1
        fi

        echo "L'utilisateur '$1' a ete créé avec succès!"
        return 0
}

add_password() {
        if ! id -u "$1" >/dev/null 2>&1; then
                echo "L'utilisateur $1 n'existe pas!"
                return 1
        fi

        local password="$2"
        echo "$1:$password" | chpasswd

        if [ "$?" -ne 0 ]; then
                echo "Impossible de définir le password de l'utilisateur $1"
                return 1
        fi
        echo "Mot de passe de $1 créé avec succès!"
        return 0
}

install_nginx() {
        apt update
        apt install -y nginx

        if [ "$?" -ne 0 ]; then
                echo "Impossible d'installer nginx"
                return 1
        fi
        echo "nginx a été installé avec succès!"
        return 0
}

configure_site() {
        if [ "$#" -ne 2 ]; then
                echo "Usage: $0 configure_site <site_name> <http_port> "
                return 1
        fi
        site_name="$1"
        http_port="$2"

        config="/etc/nginx/sites-available/default"
        new_config="/etc/nginx/sites-available/$site_name"
        web_root="/var/www/$site_name"

        mkdir -p "$web_root"
        if [ "$?" -ne 0 ]; then
                echo "Impossible de créer le repertoire pour $site_name"
                return 1
        fi
        echo "<html><head><title>$site_name</title></head><body><h1>$site_name</h1></body></html>" > "$web_root/index.html"
        if [ "$?" -ne 0 ]; then
        echo "Impossible de créer le fichier index.html pour $site_name"
        return 1
        fi

        cp "$config" "$new_config"
        if [ "$?" -ne 0 ]; then
        echo "Impossuble de créer le fichier de config pour $site_name"
        return 1
        fi

        sed -i "s/server_name .*/server_name $site_name;/" "$new_config"
        sed -i "s/listen [[:digit:]]\+ default_server/listen $http_port default_server;/" "$new_config"
        sed -i "s/listen \[::]:[[:digit:]]\+ default_server/listen [::]:$http_port default_server;/" "$new_config"
        sed -i "s/root .*/root $web_root;/" "$new_config"
        echo " fichier config de $1 a été créé avec succès : $new_config"

        echo "Fichier config de $site_name créé avec succès : $new_config"
        echo "Fichier index.html crée avec succes: $web_root/index.html"
        return 0
}

active_site() {
        if [ "$#" -ne 1 ]; then
                echo "Usage: $0 active_site <site_name>"
                return 1
        fi
        site_name="$1"
        config_file="/etc/nginx/sites-available/$site_name"
        enabled_link="/etc/nginx/sites-enabled/$site_name"

        nginx -t -c "/etc/nginx/nginx.conf" >/dev/null 2>&1
        if [ "$?" -ne 0 ]; then
                echo "La syntaxe de la config est incorrect pour $site_name"
                return 1
        fi
        ln -sf "$config_file" "$enabled_link"
        if [ "$?" -ne 0 ]; then
                echo "Impossible de creer le lien symbolique pour activer $site_name"
                return 1
        fi

        systemctl reload nginx
        if [ "$?" -ne 0 ]; then
                echo "Impossible de recharger nginx"
                return 1
        fi
        echo "$site_name a éte créé avec succès"
        return 0

}

add_cronjob() {
        if [ "$#" -ne 1 ]; then
                echo "Usage: $0 add_cronjob <file_name>"
                return 1
        fi
        file_name="$1"
        if [ ! -f "$file_name" ]; then
                echo "$file_name n'existe pas!"
                return 1
        fi
        (crontab -l ; echo "*/5 * * * * ~/disk_monitor.sh >>$file_name") | crontab -
        echo "cron reussi "
}

if [ "$1" = "user" ]; then
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 user <username> <password>"
    exit 1
  fi
  create_user "$2"
  add_password "$2" "$3"
elif [ "$1" = "install" ]; then
  install_nginx
elif [ "$1" = "configure_site" ]; then
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 configure_site <site_name> <http_port>"
    exit 1
  fi
  shift
  configure_site "$@"
elif [ "$1" = "active_site" ]; then
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 active_site <site_name>"
    exit 1
  fi
  shift
  active_site "$@"
elif [ "$1" = "add_cronjob" ]; then
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 add_cronjob <file_name>"
    exit 1
  fi
  shift
  add_cronjob "$@"
else
  echo "Usage: $0 user <username> <password> or $0 install or $0 configure_site <site_name> <http_port> or $0 active_site <site_name> or $0 add_cronjob <file_name>"
  exit 1
fi
~                                             
