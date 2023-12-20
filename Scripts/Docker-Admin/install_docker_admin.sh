#!/bin/bash
# Desenvolvido por: Aldenízio dos S. Silva
# url de canais
# docker.io/library/ubuntu:22.04
# docker.io/library/ubuntu:20.04
# docker.io/library/ubuntu:18.04

#configuraçao
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

function download_docker_admin() {
#URL DO ARQUIVO
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=16qCmNAQHrPz6tSlmwnHSIXGPhSQlIQqy' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=16qCmNAQHrPz6tSlmwnHSIXGPhSQlIQqy" -O /tmp/docker_admin.tar.gz
}

clear

RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

case "$RELEASE" in
    bionic)
        echo "É UBUNTU 18.04 BIONIC"
	sleep 2
    ;;
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
DEBIAN_FRONTEND=noninteractive apt-get -y -qq install language-pack-gnome-pt language-pack-pt-base myspell-pt myspell-pt-br wbrazilian wportuguese software-properties-common
localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR
update-locale
locale-gen --purge
dpkg-reconfigure --frontend noninteractive locales

clear
echo "INSTALANDO PHP E APACHE2"
sleep 2
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -qq install apache2 php php-bcmath php-ldap php-bcmath php-bz2 php-cli php-common php-curl php-gd php-json php-mbstring php-soap php-sqlite3 php-xml php-xmlrpc php-zip unzip zip php-common sshfs

clear
echo "CONFIGURANDO PHP"
sleep 2
PHPPATH=/etc/php/$(ls /etc/php | head -n 1)/apache2/php.ini
sed_configuracao "default_socket_timeout = 60000" "$PHPPATH"
sed_configuracao "max_execution_time = 60000" "$PHPPATH"
sed_configuracao "max_input_time = 60000" "$PHPPATH"
sed_configuracao "upload_max_filesize = 8192M" "$PHPPATH"
sed_configuracao "post_max_size = 8192M" "$PHPPATH"

APACHECNF=/etc/apache2/apache2.conf
sed_configuracao "Timeout 600" "$APACHECNF"

sed -i "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf

clear
echo "INSTALANDO DOCKER"
sleep 2
apt-get update
curl -fsSL https://get.docker.com/ | sh

clear
echo "CONFIGURANDO DOCKER"
sleep 2
cat << CONF > /etc/docker/daemon.json
{
        "storage-driver": "devicemapper",
        "storage-opts": [
                "dm.basesize=25G"
        ]
}
CONF


clear
echo "ADICIONANDO www-data AOS USUÁRIO QUE PODEM EXECUTAR sudo docker SEM INFORMAR SENHA"
sleep 2
echo 'www-data ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker' | sudo EDITOR='tee -a' visudo

clear
echo "REINICIANDO DOCKER"
sleep 2
/etc/init.d/docker restart

clear
echo "FAZENDO DOWNLOAD DAS FONTES"
sleep 2
download_docker_admin

clear
echo "EXTRAINDO ARQUIVOS"
sleep 2
cd /tmp
tar -xzf docker_admin.tar.gz
rm /var/www/html/index.html
mv /tmp/docker_admin /var/www/html
chmod 775 -R /var/www/html
chown www-data -R /var/www/html

clear
echo "CRIANDO INDEX.HTML"
sleep 2
cat << INDEX > /var/www/html/index.html
<html>
<head>
<title>DOCKER ADMIN</title>
<meta http-equiv="refresh" content="0;URL=docker_admin" />
</head>
<body>
</body>
</html>

INDEX

clear
echo "REINICIADO SERVIÇOS"
sleep 2
/etc/init.d/apache2 restart

clear
echo "INSTALAÇÃO TERMINADA,SISTEMA INSTALADO,USUARIO:admin SENHA:admin,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)"
