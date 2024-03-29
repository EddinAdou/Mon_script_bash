Ce script bash permet de créer un nouvel utilisateur, d'installer et configurer un site nginx, d'activer la configuration du site et de planifier une tâche cron pour surveiller l'espace disque.
Utilisation
Création d'un utilisateur

Pour créer un nouvel utilisateur, utilisez la commande suivante :

./monscript.sh user <nom_utilisateur> <mot_de_passe>

Remplacez <nom_utilisateur> par le nom d'utilisateur souhaité et <mot_de_passe> par le mot de passe souhaité.
Installation de nginx

Pour installer nginx, utilisez la commande suivante :

./monscript.sh install

Cette commande mettra à jour les repositories et installera le paquet nginx.
Configuration d'un site

Pour configurer un site nginx, utilisez la commande suivante :

./monscript.sh configure_site <nom_site> <port>

Remplacez <nom_site> par le nom souhaité pour le site et <port> par le port souhaité pour le site.

Cette commande créera un fichier de configuration nginx dans le répertoire /etc/nginx/sites-available avec le nom <nom_site>, remplacera le port http, le server_name et le root de la configuration nginx du site, créera un dossier avec le même nom que le site dans le répertoire /var/www, générera un fichier index.html dans ce dossier et affichera le nom du site dans ce fichier.
Activation d'un site

Pour activer la configuration d'un site nginx, utilisez la commande suivante :

./monscript.sh active_site <nom_site>

Remplacez <nom_site> par le nom du site que vous souhaitez activer.

Cette commande vérifiera la syntaxe de la configuration du site, puis rechargera le service nginx pour activer la configuration.
Ajout d'une tâche cron

Pour ajouter une tâche cron qui enregistre le message "Disk space almost full {percentage}% used." dans un fichier toutes les 5 minutes si l'espace disque dépasse les 10%, utilisez la commande suivante :

./monscript.sh add_cronjob

Cette commande créera un script bash disk_monitor.sh qui vérifie l'espace disque et retourne la chaîne "Disk space almost full {percentage}% used." si l'espace disque dépasse les 10%. Ensuite, elle planifiera une tâche cron pour exécuter ce script toutes les 5 minutes et enregistrer le résultat dans un fichier.
