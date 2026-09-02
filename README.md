# oficina-infra-db

Infraestrutura como código (Terraform) para provisionar o banco de dados RDS PostgreSQL na AWS.

## Responsabilidade

Provisiona e gerencia o banco de dados relacional utilizado pela aplicação `fiap-oficina` e pela Lambda de autenticação `oficina-lambda`.

## Tecnologias

| Tecnologia | Uso |
|---|---|
| Terraform >= 1.5 | Provisionamento de infraestrutura |
| AWS RDS | Banco de dados gerenciado |
| PostgreSQL 16.9 | Engine do banco |
| AWS S3 | Backend remoto do Terraform state |
| GitHub Actions | CI/CD (validate + plan + apply) |

## Arquitetura

```
GitHub Actions
  │
  ├── Push qualquer branch → terraform validate + plan
  └── Merge em main → terraform apply
            │
            ▼
      AWS RDS PostgreSQL 16.9
      db.t3.micro (free tier)
      oficina-db.claqg4404q5p.sa-east-1.rds.amazonaws.com:5432
            │
            ├── fiap-oficina (Spring Boot no EKS)
            └── oficina-lambda (autenticação por CPF)
```

## Recursos provisionados

- **RDS PostgreSQL 16.9** — instância `db.t3.micro` (free tier)
- **Security Group** — libera porta 5432
- **DB Subnet Group** — usa subnets da VPC padrão

## Infraestrutura ativa

| Recurso | Valor |
|---|---|
| **Endpoint** | `oficina-db.claqg4404q5p.sa-east-1.rds.amazonaws.com` |
| **Porta** | `5432` |
| **Banco** | `oficina` |
| **Instância** | `db.t3.micro` (free tier) |

> O schema do banco é criado automaticamente pelo Flyway quando o `fiap-oficina` inicializa no EKS.

## Fluxo de branches e CI/CD

```
develop → homolog (só CI) → main (deploy automático via PR)
```

- Push em qualquer branch → CI roda `terraform validate` + `terraform plan`
- Merge em `main` → `terraform apply` automático

## Execução local

```bash
terraform init
terraform plan -var="db_password=sua-senha"
terraform apply -var="db_password=sua-senha"
```

## Outputs

| Output | Descrição |
|---|---|
| `db_endpoint` | Endpoint completo (host:porta) |
| `db_host` | Host para configurar no secret `DB_HOST` |
| `db_port` | Porta (5432) |
| `db_name` | Nome do banco (oficina) |

## Após o deploy

Copie o valor de `db_host` do output e atualize o secret `DB_HOST` nos repositórios:
- `oficina-lambda` (environments: homolog e production)
- `oficina-infra-k8s` (secrets do GitHub Actions)

## Secrets necessários no GitHub

| Secret | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `DB_PASSWORD` | Senha do banco de dados |
