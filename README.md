# oficina-infra-db

Infraestrutura como código (Terraform) para provisionar o banco de dados RDS PostgreSQL na AWS.

## Recursos provisionados

- **RDS PostgreSQL 16.9** — instância `db.t3.micro` (free tier)
- **Security Group** — libera porta 5432
- **DB Subnet Group** — usa subnets da VPC padrão

## Pré-requisitos

- Terraform >= 1.5
- AWS CLI configurado
- Bucket S3 `oficina-terraform-state-302789973247` (já criado)

## Execução local

```bash
terraform init
terraform plan -var="db_password=sua-senha"
terraform apply -var="db_password=sua-senha"
```

## Outputs

Após o apply, os seguintes valores estarão disponíveis:

| Output | Descrição |
|---|---|
| `db_endpoint` | Endpoint completo (host:porta) |
| `db_host` | Host para configurar no secret `DB_HOST` |
| `db_port` | Porta (5432) |
| `db_name` | Nome do banco (oficina) |

## Fluxo de branches

```
develop → homolog (só CI) → main (deploy automático via PR)
```

- Push em qualquer branch → CI roda `terraform validate` + `terraform plan`
- Merge em `main` → `terraform apply` automático

## Secrets necessários no GitHub

| Secret | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `DB_PASSWORD` | Senha do banco de dados |

## Infraestrutura provisionada

- **Endpoint:** `oficina-db.claqg4404q5p.sa-east-1.rds.amazonaws.com`
- **Porta:** `5432`
- **Banco:** `oficina`

## Após o deploy

Copie o valor de `db_host` do output e atualize o secret `DB_HOST` nos repositórios:
- `oficina-lambda` (environment: homolog)
- `oficina-app` (environment: homolog)

> O schema do banco é criado automaticamente pelo Flyway quando o `oficina-app` inicializa no EKS.
