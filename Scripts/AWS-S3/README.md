# Backup de diretório movido para S3 (BashScript)

---
## Descrição
Esse script realiza o backup e move para S3, basta criar um backup de diretório e mover esse arquivo de backup compactado para um bucket S3 configurado com a ajuda do script bash e do usuário AWS IAM com acesso total ao S3. Foi adicionado um novo recurso: o script será adequado para o repositório Ubuntu/RedHat e o script instalará as dependências como ele mesmo. Então, vamos rodar!

----
## Recursos
- Fácil de configurar 
- Ele gera o formato compactado do diretório
- Todas as etapas serão fornecidas, incluindo usuário AWS IAM e criação de bucket S3
- Inclui instalação AWSCLI de acordo com sua distribuição Ubuntu/RedHat
- Você pode utilizar variáveis já pré-definidas ou utilizar suas respostas durante a execução do script

## Con
- Para utilizar no Cronjob ative as váriáveis #con1 #patch #bucket 

----
## Pré-Requisitos
- Conhecimento básico de Bash
- Conhecimento básico do serviço AWS IAM, S3
- É necessário alterar suas credenciais de usuário IAM e, em seguida, insira as mesmas durante o tempo de execução do script

----
### Pré-solicitado (pacotes de dependência)
```sh
apt install -y git
```

### Como baixar e dar permissão
```sh
git clone https://github.com/ninholhc/backup-S3.git
cd backup-S3-script
chmod +x backup-S3.sh
```

Comando para executar o script::
```sh
[root# ./backup-S3.sh
# --------------------------- ou --------------------------------- #
[root# bash backup-S3.sh
```

----
## Conclusão
É um script bash simples para fazer backup de diretórios (compactados) e mover para o bucket S3 mencionado com a ajuda do usuário AWS IAM.

### ⚙️ Contato

<p align="center">
<a href="mailto:aldenizio.ninho@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a><br />
