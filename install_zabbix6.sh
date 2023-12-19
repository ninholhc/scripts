#!/bin/bash


#atribui configuraçao
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
        echo "É UBUNTU 20.04 FOCAL CONTINUANDO"
	sleep 2
	echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    	apt-key adv --keyserver keyserver.ubuntu.com --recv 7FCC7D46ACCC4CF8
    	;;
    jammy)
        echo "É UBUNTU 22.04 JAMMY CONTINUANDO"
        cp /etc/apt/sources.list /etc/apt/sources.list.d/focal.list
        sed -i 's/jammy/focal/g' /etc/apt/sources.list.d/focal.list
        touch /etc/apt/sources.list.d/pgdg.list
    	echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    	apt-get --force-yes --yes install curl ca-certificates gnupg
    	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg
        add-apt-repository -y ppa:ondrej/php
        apt-get update
        
	sleep 2
    ;;
    *)
        echo "RELEASE UBUNTU NÃO ENCONTRADA,SAÍNDO"
	sleep 2
	exit
    ;;
esac


clear
echo "AJUSTANDO REPOSITÓRIOS"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list
apt-get update

clear
echo "AJUSTANDO IDIOMA"
sleep 2
apt-get update
apt-get --force-yes --yes install language-pack-gnome-pt language-pack-pt-base myspell-pt myspell-pt-br wbrazilian wportuguese


clear
echo "CONFIGURANDO PORTUGUÊS"
sleep 2
if [[ -z $(grep reorder-after /usr/share/i18n/locales/pt_BR) ]]; then 
    sed -i '/^copy \"iso14651_t1\"/areorder-after <U00A0>\n<U0020><CAP>;<CAP>;<CAP>;<U0020>\nreorder-end' /usr/share/i18n/locales/pt_BR    
fi

chmod 777 /var/lib/locales/supported.d/pt
echo "pt_BR.ISO-8859-1 ISO-8859-1" >> /var/lib/locales/supported.d/pt
localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR 
update-locale 
locale-gen --purge
dpkg-reconfigure --frontend noninteractive locales

clear
echo "INSTALANDO POSTGRESQL"
sleep 2
apt-get update
apt-get --force-yes --yes install postgresql postgresql-client postgresql-contrib

sed -i 's/md5$/trust/g' /etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf
sed -i 's/peer$/trust/g' /etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf

/etc/init.d/postgresql restart

clear
echo "CRIANDO USUÁRIO"
sleep 2
psql -U postgres -c "CREATE ROLE zabbix WITH SUPERUSER LOGIN PASSWORD 'zabbix';"

clear
echo "CRIANDO DATA-BASE"
sleep 2
psql -U postgres -c "CREATE DATABASE zabbix OWNER zabbix;"

clear
echo "INSTALANDO PHP E APACHE"
sleep 2

case "$RELEASE" in
    bionic)
        apt-get --force-yes --yes install apache2 php7.4-fpm php7.4 php7.4-mbstring php7.4-gd php7.4-xml php7.4-bcmath php7.4-ldap php7.4-pgsql libapache2-mod-fcgid
        PHP_INI=/etc/php/$(ls /etc/php)/fpm/php.ini
    	;;
    focal)
        apt-get --force-yes --yes install apache2 php-fpm php php-mbstring php-gd php-xml php-bcmath php-ldap php-pgsql libapache2-mod-fcgid
        PHP_INI=/etc/php/7.4/apache2/php.ini
    	;;
    jammy)
        apt-get --force-yes --yes install apache2 php7.4-fpm php7.4 php7.4-mbstring php7.4-gd php7.4-xml php7.4-bcmath php7.4-ldap php7.4-pgsql libapache2-mod-fcgid
        PHP_INI=/etc/php/$(ls /etc/php)/fpm/php.ini
    	;;
    *)
        ;;
esac


clear
echo "CONFIGURANDO PHP"
sleep 2
PHP_INI=/etc/php/$(ls /etc/php)/apache2/php.ini
sed_configuracao "max_execution_time = 300" "$PHP_INI"
sed_configuracao "memory_limit = 256M" "$PHP_INI"
sed_configuracao "post_max_size = 16M" "$PHP_INI"
sed_configuracao "max_input_time = 300" "$PHP_INI"
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHP_INI"
sed_configuracao "upload_max_filesize 16M" "$PHP_INI"
sed_configuracao "max_input_vars 10000" "$PHP_INI"
PHP_INI=/etc/php/$(ls /etc/php)/fpm/php.ini
sed_configuracao "max_execution_time = 300" "$PHP_INI"
sed_configuracao "memory_limit = 256M" "$PHP_INI"
sed_configuracao "post_max_size = 16M" "$PHP_INI"
sed_configuracao "max_input_time = 300" "$PHP_INI"
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHP_INI"
sed_configuracao "upload_max_filesize 16M" "$PHP_INI"
sed_configuracao "max_input_vars 10000" "$PHP_INI"

clear
echo "ADICIONANDO REPOSITÓRIO ZABBIX"
sleep 2
case "$RELEASE" in
    bionic)
    	ZBX=$(wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/ -4 -O zbx.html; cat zbx.html | grep 18.04 | grep .deb | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr ' ' '\n' | tail -n 1)
    ;;
    focal)
    	ZBX=$(wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/ -4 -O zbx.html; cat zbx.html | grep 20.04 | grep .deb | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr ' ' '\n' | tail -n 1)
    ;;
    jammy)
    	ZBX=$(wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/ -4 -O zbx.html; cat zbx.html | grep 22.04 | grep .deb | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr ' ' '\n' | tail -n 1)
    ;;
    *)
        echo "RELEASE UBUNTU NÃO ENCONTRADA,SAÍNDO"
	sleep 2
	exit
    ;;
esac

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/$ZBX -4
ZBX_VER=$(ls | grep zabbix-release | cut -d'_' -f2 | cut -d'+' -f1 | sed "s/-/./")
dpkg -i $(ls | grep zabbix-release)

case "$RELEASE" in
    jammy)
    	sed -i 's/jammy/focal/g' /etc/apt/sources.list.d/zabbix.list
    ;;
    *)
    ;;
esac

apt-get update

clear
echo "INSTALANDO ZABBIX"
sleep 2
apt-get --force-yes --yes install zabbix-server-pgsql zabbix-sql-scripts zabbix-frontend-php zabbix-agent

clear
echo "CONFIGURANDO ZABBIX"
sleep 2
ZABBIX_CONF="/etc/zabbix/zabbix_server.conf"

case "$RELEASE" in
    jammy)
    ;;
    *)
    sed_configuracao "DBHost=localhost" "$ZABBIX_CONF"
    ;;
esac

sed_configuracao "DBName=zabbix" "$ZABBIX_CONF"
sed_configuracao "DBUser=zabbix" "$ZABBIX_CONF"
sed_configuracao "DBPassword=zabbix" "$ZABBIX_CONF"

clear
echo "REINICIANDO ZABBIX"
sleep 2
/etc/init.d/zabbix-server restart

clear
echo "INSTALANDO INTERFACE WEB"
sleep 2

cat << INDEX > /var/www/html/index.html
<html>
<head>
<title>zabbix</title>
<meta http-equiv="refresh" content="0;URL=zabbix" />
</head>
<body>
</body>
</html>

INDEX
mkdir /var/www/html/zabbix
wget https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${ZBX_VER}.tar.gz
tar -xvzf zabbix-${ZBX_VER}.tar.gz
cp -R zabbix-${ZBX_VER}/ui/* /var/www/html/zabbix


clear
echo "POPULANDO BASE INICIAL"
sleep 2
psql -U zabbix -d zabbix -f zabbix-${ZBX_VER}/database/postgresql/schema.sql
psql -U zabbix -d zabbix -f zabbix-${ZBX_VER}/database/postgresql/images.sql
psql -U zabbix -d zabbix -f zabbix-${ZBX_VER}/database/postgresql/data.sql


clear
echo "INSTALANDO FIREWALL CMD"
sleep 2
apt-get --force-yes --yes install firewall-config

clear
echo "AJUSTANDO FIREWALL"
sleep 2
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --reload

clear
echo "AJUSTES FINAIS"
sleep 2
chmod 777 -R /var/www/html
a2enmod actions fcgid alias proxy_fcgi proxy
a2enconf $(ls /etc/apache2/conf-available | grep php | grep fpm | cut -d'.' -f1-2)
/etc/init.d/$(ls /etc/init.d | grep php) restart
/etc/init.d/apache2 restart

clear
echo "INSTALAÇÃO TERMINADA,ZABBIX INSTALADO,USUARIO:Admin SENHA:zabbix,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB COM O IP DESSA MÁQUINA OU NOME HOST"
