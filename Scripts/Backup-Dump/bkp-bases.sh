#!/bin/bash
# Desenvolvido por: Aldenízio dos S. Silva
# Script para criacao de dumps dos bancos MySQL e PostgreSQL

# -- Variaveis de Ambiente ---

DATA=$(date +%Y-%m-%d_%H-%M)

# Diretorio local de backup
PBACKUP="/backup"

# Diretorio remoto de backup
RBACKUP="/backup/dumps"

# Usuario e host de destino
# SDESTINO="dumper@IP_remoto"

HOST=$(hostname)

# Envio de e-mail confirmando o backup
EMAIL="seu_email"


# Acesso ao Postgreslq
#POSTGRESQL --

DBNAME="dbname"
USER="user"
PASSWORD="password"


# -- LIMPEZA ---
# Os arquivos dos últimos 5 dias serão mantidos
NDIAS="5"

if [ ! -d ${PBACKUP} ]; then
	
	echo ""
	echo " A pasta de backup nao foi encontrada!"
	mkdir -p ${PBACKUP}
	echo " Iniciando Tarefa de backup..."
	echo ""

else

	echo ""
	echo " Rotacionando backups mais antigos que $NDIAS"
	echo ""

	find ${PBACKUP} -type d -mtime +$NDIAS -exec rm -rf {} \;

fi

# Comentar algum procedimento na cron
# Exemplo para uma linha que contenha "php"
# Adiciona um "#" no comeco da linha
sed -i '/php/s/^/#/g' /etc/crontab

# -- SCRIPT ---


### Postgres

if [ ! -d $PBACKUP/$DATA/postgres ]; then

        mkdir -p $PBACKUP/$DATA/postgres

fi

chown -R postgres:postgres $PBACKUP/$DATA/postgres/


su - postgres -c "vacuumdb -a -f -z"

for bdpostgres in $(su - postgres -c "psql -l" | grep -v template0|grep -v template1|grep "|" |grep -v Owner |awk '{if ($1 != "|" && $1 != "Nome") print $1}'); do

        su - postgres -c "pg_dump $bdpostgres > $PBACKUP/$DATA/postgres/$bdpostgres.txt"

        cd $PBACKUP/$DATA/postgres/

        tar -czvf $bdpostgres.tar.gz $bdpostgres.txt
		
		sha1sum $bdpostgres.tar.gz > $bdpostgres.sha1

        rm -rf $bdpostgres.txt

	cd /

done


# Backup de usuarios do Postgresql

su - postgres -c "pg_dumpall --globals-only -S postgres > $PBACKUP/$DATA/postgres/usuarios.sql"


DAYOFWEEK=$(date +"%u")
if [ "${DAYOFWEEK}" -eq 7  ];  then

  # Otimizacao das tabelas
  su - postgres -c "vacuumdb -a -f -z"
  
  # Backup de todo o banco
  su - postgres -c "pg_dumpall > $PBACKUP/$DATA/postgres/postgres_completo.txt"
  
  cd ${PBACKUP}/${DATA}/postgres/

  tar -czvf postgres_completo.tar.gz postgres_completo.txt
   
  sha1sum postgres_completo.tar.gz > postgres_completo.sha1

  rm -f postgres_completo.txt  

fi


# Verifica se existe um diretorio com o nome do host no host remoto
if [ $(ssh  $SDESTINO "ls ${RBACKUP}" |grep -i $HOST |wc -l) = 0 ]; then

        ssh  $SDESTINO "mkdir -p ${RBACKUP}/$HOST"

fi

# Descomenta na cron alguma linha que foi comentada para a realizacao do backup
# Exemplo para uma linha que contenha "php"
# Remove um "#" no comeco da linha
sed -i '/php/s/^#//g' /etc/crontab

echo "Backup finalizado" |mutt -s "Backup $HOST Finalizado!" $EMAIL

# Realiza otimizacao das tabelas aos domingos

DAYOFWEEK=$(date +"%u")
if [ "${DAYOFWEEK}" -eq 7  ];  then

 #Otimizacao das tabelas 
/usr/bin/mysqlcheck -A -o -u root --password=senha-root

fi

exit 0