#!/bin/bash

Ubuntu=$(which apt > 2&>1; echo $?)
Redhat=$(which yum > 2&>1; echo $?)
AWS=$(which aws > 2&>1; echo $?)
date=$(date "+%d%m%Y")
con1=N
path=/backup
bucket=informe o nome do bucket

if [[ "$AWS" -eq 0 ]]; then
	echo "AWS sendo instalado....."
	echo ""
	echo "Iniciando o script..."
	
	if [[ $(ls ~/.aws/credentials > 2&>1; echo $?) -ne 0 ]]; then
		echo ""
		echo "Por favor, configure seus creds de usuário IAM no servidor"
		echo ""
		aws configure --profile backups3
		echo ""
		echo "Vamos rolar para criar seu backup para S3"
	fi
elif [[ "$Ubuntu" -eq 0 ]]; then
	echo "AWS O pacote não está instalado na sua distribuição Ubuntu. Instalando o pacote AWS...."
	sleep 1
	echo ""
	sudo apt install -y awscli
	echo "Por favor, configure seus creds de usuário IAM no servidor"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Vamos rolar para criar seu backup para S3"
elif [[ "$Redhat" -eq 0 ]]; then
	echo "Pacote AWS não está instalado em sua distribuição ReadHat. Instalando o pacote AWS...."
	sleep 1
	echo ""
	sudo yum install -y awscli
	echo "Por favor, configure seus creds de usuário IAM no servidor"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Vamos rolar para criar seu backup para S3"
else
	echo "Instale o Pacote AWS..... e repita o mesmo"
	exit 1
fi

isInFileA=$(cat ~/.aws/credentials | grep -c "backups3")
isInFileB=$(cat ~/.aws/config | grep -c "backups3")
CredInServer=~/.aws/credentials
# AWS Configuration on the server
if [ -f $CredInServer ] && [ "$isInFileA" -eq 1 ] && [ "$isInFileB" -eq 1 ]; then
    echo ""
	echo "Por favor, verifique as credenciais fornecidas abaixo"
    echo ""
    cat $CredInServer | grep -A 2 "backups3" | tail -n2
    echo ""
    #read -p "Você precisa reconfigurar o mesmo [Y/N]: " $con1
    if [[ "$con1" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        aws configure --profile backups3
    else
        echo ""
        echo "Vamos rolar para criar seu backup para S3"
    fi
else
	echo ""
    echo "Por favor, configure seus creds de usuário IAM no servidor"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Vamos rolar para criar seu backup para S3"
fi

isInFileA=$(cat ~/.aws/credentials | grep -c "backups3")
isInFileB=$(cat ~/.aws/config | grep -c "backups3")
CredInServer=~/.aws/credentials
# Taking a local Backup before S3 upload
if [ -f $CredInServer ] && [ "$isInFileA" -eq 1 ] && [ "$isInFileB" -eq 1 ]; then
	echo ""
	#read -p "Digite o caminho do diretório (o diretório será compactado como um arquivo tar.gz): " path
	BackupName=$(echo $path | awk -F "/" '{print $NF}')			
	if [ -z $path ]; then 
		echo "Especifique um caminho de diretório absoluto"
		exit 1
	else
		if [[ "$path" == */ ]]; then
			echo "O caminho do diretório digitado termina com /, portanto, remova o último símbolo /"
		else
			if [ -d $path ]; then
				echo ""
				echo "Tomando o caminho do diretório para o seu local como um temporário........."
				echo ""
				sleep 2
				rm -f /tmp/$BackupName-*.tar.gz 
				tar -cvf /tmp/$BackupName-$date.tar.gz $path/
				echo ""
				echo "O backup local foi criado com sucesso...."
				# Backup Copy to S3
				echo ""
				#read -p "Insira o nome do seu bucket (destino S3): " bucket
				if [ -z $bucket ]; then
					echo "Especifique o nome do bucket"
					exit 1
				else				
					if [ $(aws s3 --profile backups3 ls | grep -w "$bucket" > 2&>1; echo $?) -eq 0 ]; then
						echo "Backup Movendo para S3......."
						aws s3 --profile backups3 cp "/tmp/$BackupName-$date.tar.gz" s3://$bucket/backup/
						echo ""
						echo "Removendo backup local....."
						rm -f /tmp/$BackupName-*.tar.gz 
						echo "O backup local foi removido com sucesso"
					else
						echo ""
						echo "Insira um nome do bucket válido"
						exit 1
					fi
				fi
			else
				echo ""
				echo "Digite um caminho absoluto de diretório válido"
			fi
		fi
	fi
fi