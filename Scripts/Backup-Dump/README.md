# Backup BD
Script em Bash (Linux) para backup de bancos MySQL e Postgresql
- Pré-requisitos: pacotes mutt para envio de e-mails com anexos
- Criação de chaves para acesso de SSH dos servidores de banco de dados para os repositórios remotos

# MySQL:
Deverá ser criado um usuário dumper ou similar com permissões em todas as bases
- Exemplo: GRANT ALL PRIVILEGES ON *.* TO dumper@localhost IDENTIFIED BY 'lhc2023' WITH GRANT OPTION;
# Postgres:
Dever ser permitido o localhost como trust no arquivo pg_hba.conf
# Armazenamento remoto:
Deverá ser permitido ao usuário root local acessar por SSH, com certificado no host remoto, com o usuário onde será o armazenamento dos dumps
