### **Conteúdo do README.md no Diretório `configs`**

# Configs Directory

Este diretório contém os arquivos de configuração usados para os processos de backup e restauração do **GitLab CE**. Essas configurações incluem exemplos de variáveis de ambiente e instruções para personalização.

---

## **Arquivos**

### 1. `example-env.sh`
Um arquivo de exemplo que lista as variáveis de ambiente necessárias para a execução local dos scripts de backup e restauração. Essas variáveis incluem:
- Credenciais de acesso ao MinIO.
- Informações do bucket e endpoint do MinIO.
- Diretórios de backup.

### **Conteúdo do `example-env.sh`:**
```bash
# MinIO Configuration
MINIO_ENDPOINT="https://s3-api.it.com"
MINIO_BUCKET="gitlabce"
ACCESS_KEY="The-access-key"
SECRET_KEY="The-secret-key"

# Local Backup Directory
BACKUP_DIR="/backups"
```

---

## **Como Usar**

1. **Personalize o `example-env.sh`**:
   Copie o arquivo para um novo arquivo chamado `env.sh`:
   ```bash
   cp configs/example-env.sh configs/env.sh
   ```
   Edite o `env.sh` com as configurações específicas do seu ambiente.

2. **Carregue as Variáveis de Ambiente**:
   Antes de executar scripts manualmente ou testes locais, carregue as variáveis:
   ```bash
   source configs/env.sh
   ```

3. **Uso em Kubernetes**:
   As variáveis de ambiente deste arquivo são usadas como referência para configurar o `ConfigMap` e `Secret` nos manifestos Kubernetes.

---

## **Observação**

Certifique-se de proteger os arquivos que contêm credenciais, como `ACCESS_KEY` e `SECRET_KEY`. Evite armazenar essas informações em repositórios públicos sem encriptação ou proteção adequada.

Para mais informações sobre como configurar os backups e restaurações, consulte o [README principal](../README.md).
