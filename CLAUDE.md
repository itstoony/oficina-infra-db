# CLAUDE.md — oficina-infra-db
## FIAP Pós-Tech Software Architecture — Fase 3

---

## CONTEXTO

Este repositório provisiona o **banco de dados RDS PostgreSQL** da Fase 3 via Terraform.

**Account ID:** 302789973247
**Região:** sa-east-1
**Bucket state Terraform:** `oficina-terraform-state-302789973247`

**Os 4 repositórios da Fase 3:**
- `oficina-lambda` → https://github.com/itstoony/oficina-lambda.git — **CONCLUÍDO**
- `oficina-infra-db` ← este repositório
- `oficina-infra-k8s` → https://github.com/itstoony/oficina-infra-k8s.git
- `oficina-app` → https://github.com/itstoony/fiap-oficina.git

---

## PADRÕES DO PROJETO

- Commits em **português do Brasil** seguindo conventional commits
- Branches: `develop` → `homolog` → `main`
- `main` protegida: PR obrigatório com 1 aprovação + CI verde
- Sem co-authoria de ferramentas nos commits

---

## RESPONSABILIDADE

Provisionar via Terraform:
- RDS PostgreSQL 16.3 (`db.t3.micro` — free tier)
- Security Group liberando porta 5432
- DB Subnet Group usando VPC padrão

---

## ESTRUTURA

```
oficina-infra-db/
├── main.tf                     ← RDS, Security Group, Subnet Group
├── variables.tf                ← region, db_name, db_user, db_password
├── outputs.tf                  ← db_endpoint, db_host, db_port, db_name
├── .github/
│   └── workflows/
│       ├── ci.yml              ← validate + plan em push/PR
│       └── deploy.yml          ← apply automático no merge para main
└── README.md
```

---

## DECISÕES TÉCNICAS

- **Backend S3:** estado do Terraform em `oficina-terraform-state-302789973247/db/terraform.tfstate`
- **VPC padrão:** usa a VPC default da AWS para simplicidade
- **publicly_accessible = true:** necessário para a Lambda acessar (sem VPC Link)
- **skip_final_snapshot = true:** ambiente de estudo, sem necessidade de snapshot final
- **deletion_protection = false:** facilita limpeza após o vídeo de demonstração

---

## CI/CD

| Trigger | Job | O que faz |
|---|---|---|
| push/PR em qualquer branch | CI | `terraform validate` + `terraform plan` |
| merge para `main` | Deploy | `terraform apply` automático |

> RDS é infraestrutura compartilhada — não faz sentido ter ambiente de homologação separado para banco.

---

## STATUS

- [x] `main.tf` — implementado
- [x] `variables.tf` — implementado
- [x] `outputs.tf` — implementado
- [x] `ci.yml` — implementado
- [x] `deploy.yml` — implementado
- [x] `README.md` — implementado
- [ ] Secrets no GitHub configurados
- [ ] Deploy executado — RDS ainda não provisionado

---

## SECRETS NO GITHUB

| Secret | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | credencial AWS |
| `DB_PASSWORD` | senha do banco |

---

## APÓS O DEPLOY

O output `db_host` deve ser copiado e configurado como secret `DB_HOST` em:
- `oficina-lambda` (environments: homolog e production)
- `oficina-app` (environments: homolog e production)

---

## PRÓXIMO PASSO

Configurar secrets no GitHub e fazer merge para `main` para provisionar o RDS.
Depois: atualizar `DB_HOST` nos outros repos e provisionar EKS em `oficina-infra-k8s`.
