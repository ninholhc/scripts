#!/bin/bash

function download_glpi() {
  wget https://github.com/glpi-project/glpi/archive/refs/heads/10.0/bugfixes.zip -O /tmp/glpi.zip
}

function sed_configuracao() {
	orig=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $origparm ]];then
			origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
	dest=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $destparm ]];then
			destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
case ${dest} in
	\#${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sed -i "/^$orig/c\\${1}" $2
				else
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
					fi
			fi
		;;
		*)
			echo ${1} >> $2
		;;
	esac
}
clear
RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

case "$RELEASE" in
    focal)
        echo "É UBUNTU 20.04 FOCAL"
	sleep 2
    ;;
    jammy)
        echo "É UBUNTU 22.04 JAMMY"
	sleep 2
    ;;
    *)
        echo "RELEASE INVALIDA"
	sleep 2
	exit
    ;;
esac

clear
echo "AJUSTANDO REPOSITÓRIOS"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list

clear
echo "AJUSTANDO IDIOMA"
sleep 2
apt-get update
apt-get --force-yes --yes install language-pack-gnome-pt language-pack-pt-base myspell-pt myspell-pt-br wbrazilian wportuguese software-properties-common gettext

clear
echo "INSTALANDO GIT"
sleep 2
apt-get update
apt-get --force-yes --yes install git

clear
echo "INSTALANDO CURL"
sleep 2
apt-get update
apt-get --force-yes --yes install curl

clear
echo "INSTALANDO UNZIP"
sleep 2
apt-get update
apt-get --force-yes --yes install unzip

clear
echo "INSTALANDO MYSQL"
sleep 2
apt-get update
apt-get --force-yes --yes install mysql-server mysql-client

clear
echo "CONFIGURANDO MYSQL"
sleep 2
mysql -u root -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'glpi'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "CREATE DATABASE glpi;"
mysql -u root -e "FLUSH PRIVILEGES"

clear
echo "INSTALANDO APACHE"
sleep 2
apt-get update
apt-get --force-yes --yes install apache2


clear
echo "INSTALANDO PHP"
sleep 2
apt-get update
case "$RELEASE" in
    bionic)
    	add-apt-repository -y ppa:ondrej/php
        sudo apt-get --force-yes --yes install php7.4 php7.4-cli libapache2-mod-php7.4 php7.4-{curl,gd,imagick,intl,apcu,memcache,imap,mysql,ldap,tidy,xmlrpc,pspell,mbstring,json,xml,gd} php7.4-zip php7.4-bz2
        wget https://getcomposer.org/installer -O composer-setup.php
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    ;;
    focal)
        sudo apt-get --force-yes --yes install php libapache2-mod-php php-{curl,gd,imagick,intl,apcu,memcache,imap,mysql,cas,ldap,tidy,pear,xmlrpc,pspell,mbstring,json,xml,gd} php-zip php-bz2
        wget https://getcomposer.org/installer -O composer-setup.php
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    ;;
    jammy)
        sudo apt-get --force-yes --yes install php libapache2-mod-php php-{curl,gd,imagick,intl,apcu,memcache,imap,mysql,cas,ldap,tidy,pear,xmlrpc,pspell,mbstring,json,xml,gd} php-zip php-bz2 composer
        ;;
    *)
        echo "RELEASE INVALIDA"
	sleep 2
	exit
    ;;
esac

clear
echo "CONFIGURANDO PHP"
sleep 2
PHPPATH=/etc/php/$(ls /etc/php | tail -1)/apache2/php.ini
sed_configuracao "short_open_tag = On" "$PHPPATH"
sed_configuracao 'upload_max_filesize = 20M' "$PHPPATH"
sed_configuracao "session.cookie_httponly = On" "$PHPPATH"
/etc/init.d/apache2 restart

clear
echo "INSTALANDO NODEJS"
sleep 2
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get --force-yes --yes install nodejs

clear
echo "FAZENDO DOWNLOAD DO GLPI"
sleep 2
ARQUIVO=0
while [[ $ARQUIVO -lt 20648 ]]
do
download_glpi
if [[ -e /tmp/glpi.zip ]]
then
ARQUIVO=$(du --threshold=M /tmp/glpi.zip | cut -f 1)
else
ARQUIVO=0
fi
if [[ $ARQUIVO -gt 20648 ]]
then
	echo "DOWNLOAD CONCLUIDO"
	break
fi
echo "FALHA AO FAZER DOWNLOAD,COMEÇANDO NOVAMENTE"
ARQUIVO=0
rm -rf /tmp/glpi.zip
done

clear
echo "EXTRAINDO E MOVENDO ARQUIVOS"
sleep 2
cd /tmp
unzip glpi.zip
mv /tmp/$(ls -d * | grep glpi- | head -n 1) /var/www/html/glpi

clear
echo "EXECUTANDO PHP"
sleep 2
cd /var/www/html/glpi
php bin/console dependencies install
php bin/console locales:compile

clear
echo "CONFIGURANDO APACHE"
sleep 2
a2enmod rewrite
cat << VHOST > /etc/apache2/sites-available/glpi.conf
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/glpi

	<Directory /var/www/html/glpi>
		DirectoryIndex index.php
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride All
		Require all granted
	</Directory>

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log combined
</VirtualHost>

VHOST

a2dissite 000-default
a2ensite glpi
chmod 777 -R /var/www/html
chown -R www-data. /var/www/html
/etc/init.d/apache2 restart
clear
echo "GLPI INSTALADO E DISPONIVEL EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1) "
