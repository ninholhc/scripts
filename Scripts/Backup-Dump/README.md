# Backup BD
Script em Bash (Linux) para backup de bancos MySQL e Postgresql
Pré-requisitos: pacotes mutt para envio de e-mails com anexos
Criação de chaves para acesso de SSH dos servidores de banco de dados para os repositórios remotos

# MySQL:
Devera ser criado um usuario dumper ou similar com permissoes em todas as bases
Exemplo: GRANT ALL PRIVILEGES ON *.* TO dumper@localhost IDENTIFIED BY 'lhc2023' WITH GRANT OPTION;
# Postgres:
Dever ser permitido o localhost como trust no arquivo pg_hba.conf
# Armazenamento remoto:
Devera ser permitido ao usuario root local acessar por SSH, com certificado no host remoto, com o usuario onde sera o armazenamento dos dumps
