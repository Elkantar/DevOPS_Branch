# Deep in system

## mettre le clavier en francais :
```
sudo dpkg-reconfigure keyboard-configuration
```
ne pas changer le modele du clavier

ensuite selectionner "French" ppour le pays et la disposition.

### appliqué les changement :
```
sudo service keyboard-setup restart
```
puis executé :
```
sudo setupcon
```

## 🔧 Partitionnement manuel du disque pour le projet Deep-in-System

## 🎯 Objectif

Créer les partitions suivantes sur un disque de 30 Go, conformément aux spécifications du projet :

| Point de montage | Taille | Système de fichiers | Remarques              |
|------------------|--------|---------------------|------------------------|
| `/`              | 15 Go  | ext4                | Partition principale   |
| `/home`          | 5 Go   | ext4                | Répertoire utilisateurs |
| `/backup`        | 6 Go   | ext4                | Sauvegardes WordPress  |
| swap             | 4 Go   | swap                | Mémoire virtuelle      |

---

## 🧰 Outils utilisés

- `fdisk` : outil de partitionnement
- `mkfs.ext4` : formatage en ext4
- `mkswap` / `swapon` : configuration de la swap
- `/etc/fstab` : montage automatique au démarrage

---

## ⚠️ Pré-requis

> ⚠️ Le disque `/dev/sda` sera complètement effacé. Assurez-vous de travailler sur un disque vierge ou une VM dédiée.

---

## ✅ Étapes détaillées

### 1. Identifier le disque

```bash
lsblk
```
Vérifiez que votre disque est bien /dev/sda.

2. Lancer fdisk
```bash
sudo fdisk /dev/sda
```

3. Créer une nouvelle table de partition GPT

Dans fdisk, tapez :
```bash
g
```
4. Créer les partitions
🔹 / – 15 Go
```sh
n          # nouvelle partition
p          # partition principale
[Entrée]   # numéro par défaut
[Entrée]   # premier secteur par défaut
+15G       # taille
```
🔹 swap – 4 Go
```sh
n
p
[Entrée]
[Entrée]
+4G
t           # changer le type
[Numéro]    # numéro de la partition swap
8200        # code pour swap
```
5. Enregistrer les modifications
```sh
w
```
6. Formater les partitions
```sh
sudo mkfs.ext4 /dev/sda1   # /
sudo mkfs.ext4 /dev/sda2   # /home
sudo mkfs.ext4 /dev/sda3   # /backup
sudo mkswap /dev/sda4      # swap
```

7. Activer la swap
```sh
sudo swapon /dev/sda4
```
8. Monter les partitions
```sh
sudo mkdir -p /mnt/root
sudo mkdir -p /mnt/root/home
sudo mkdir -p /mnt/root/backup

sudo mount /dev/sda1 /mnt/root
sudo mount /dev/sda2 /mnt/root/home
sudo mount /dev/sda3 /mnt/root/backup
```

9. Configurer le montage automatique

Ajoutez ceci à /etc/fstab :
```sh
/dev/sda1 /       ext4 defaults 0 1
/dev/sda2 /home   ext4 defaults 0 2
/dev/sda3 /backup ext4 defaults 0 2
/dev/sda4 none    swap sw       0 0
```

## SSH : 
```
sudo nano /etc/ssh/sshd_config
```

Cherche et modifie :
```sh
Port 2222
PermitRootLogin no
```
puis execute :
```sh
sudo systemctl restart ssh
```


pour ce connecter au port :
```sh
ssh -p 2222 potato@127.0.0.1
```

## 🔥 Firewall (UFW)

Installer et configurer UFW :
```sh
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser seulement les ports nécessaires :
sudo ufw allow 2222/tcp   # SSH
sudo ufw allow 80/tcp     # HTTP (WordPress)
sudo ufw allow 443/tcp    # HTTPS si tu mets SSL

# Activer
sudo ufw enable
sudo ufw status verbose
```
👉 Justification des ports :

2222 = SSH admin

80 = WordPress site web

443 = si SSL (bonus)

## 👥 User Management Part
👑 Utilisateur luffy (sudo + clé SSH)

```sh
sudo adduser luffy
sudo usermod -aG sudo luffy
```
Copie ta clé publique depuis ton PC vers le serveur :

```sh
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2222 luffy@ip_serveur
```

🥋 Utilisateur zoro (non-sudo, mot de passe) :

```sh
sudo adduser zoro
# Réponds avec ton mot de passe choisi
```

## 📂 Services Part – FTP (nami)

Installer vsftpd :  
```sh
sudo apt install vsftpd -y
```
Créer l’utilisateur nami :
```sh
sudo adduser nami
```
Configurer son accès limité à /backup :
```sh
sudo usermod -d /backup nami
```
Rendre /backup en lecture seule pour nami :
```sh
sudo chown root:root /backup
sudo chmod 755 /backup
```

Configurer vsftpd :
```sh
sudo nano /etc/vsftpd.conf
```

Vérifie :
```sh
anonymous_enable=NO
local_enable=YES
write_enable=NO
chroot_local_user=YES
```
puis :
```sh
sudo systemctl restart vsftpd
```

## 🗄️ MySQL Server

Installer MySQL :
```sh
sudo apt install mysql-server -y
```

securiser :
```sh
sudo mysql_secure_installation
```
Refuse le remote root login

Pas d’accès distant

Créer un utilisateur WordPress :

```sql
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'TonMotDePasse';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Identifiant : wpuser

Password : TonMotDePasse


## 🌐 Wordpress 

Installer Apache + PHP :
```sh
sudo apt install apache2 php php-mysql libapache2-mod-php unzip wget -y
```

Télécharge Wordpress :
```sh
cd /var/www/html
sudo rm index.html
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* .
sudo rm -rf wordpress latest.zip
```

Protéger wp-config.php :

```sh
sudo chown -R www-data:www-data /var/www/html
sudo chmod 640 /var/www/html/wp-config.php
```

Configurer Apache :
```sh
sudo nano /etc/apache2/sites-available/000-default.conf
```

Assure-toi que DocumentRoot /var/www/html est correct.

Puis :
```sh
sudo systemctl restart apache2
```
Accède à http://potato@localhost/ et finis l’installation.