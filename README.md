# Pipeline dbt Core Northwind

Este repositório demonstra uma pipeline analítica construída com **dbt Core** para o famoso conjunto de dados _Northwind_. O objetivo é mostrar, de ponta a ponta, como organizar as camadas de um warehouse (raw → silver → gold), aplicar boas práticas de modelagem e expor tabelas prontas para consumo analítico.

## Visão geral da arquitetura

```
PostgreSQL (schema raw) ──▶ Modelos Raw (bronze)
                               │
                               ├──▶ Modelos de Staging (silver)
                               │
                               └──▶ Modelos de Relatórios (gold)
```

- **Raw** (`northwind/models/raw`): replicas diretas das tabelas operacionais carregadas no Postgres através do `northwind.sql`.
- **Staging** (`northwind/models/staging`): limpeza e padronização dos dados, além de cálculos básicos (ex.: total de vendas por item).
- **Relatórios** (`northwind/models/reports`): modelos analíticos consolidados, prontos para ferramentas de BI (por exemplo `report_totalsales`).
- **Macros** (`northwind/macros`): funções utilitárias que controlam o schema de destino conforme o ambiente dbt.

## Pré-requisitos

1. Python 3.13 ou superior.
2. `dbt-postgres` (instalado via pip ou [uv](https://github.com/astral-sh/uv)).
3. Um banco PostgreSQL acessível. Você pode utilizar uma instância local via Docker, `postgres.app`, ou um serviço gerenciado.

## Configuração do ambiente Python

```bash
# clone o repositório
git clone https://github.com/<sua-organizacao>/pipeline-dbt-core-northwind.git
cd pipeline-dbt-core-northwind

# crie um ambiente isolado (opcional)
python -m venv .venv
source .venv/bin/activate

# instale dependências
pip install -e .
# ou usando uv
uv pip install -e .
```

## Preparação do banco de dados

1. Crie um banco vazio (ex.: `northwind`).
2. Carregue o script `northwind.sql` para popular as tabelas operacionais:

```bash
psql postgresql://usuario:senha@host:porta/northwind -f northwind.sql
```

3. Configure o arquivo `profiles.yml` do dbt (normalmente em `~/.dbt/profiles.yml`):

```yaml
northwind:
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: usuario
      password: senha
      dbname: northwind
      schema: analytics
  target: dev
```

> Ajuste `schema` para o schema padrão que receberá as tabelas dbt. As macros do projeto permitem sobrescrever o schema por modelo.

## Executando a pipeline

Com o ambiente configurado e o banco populado:

```bash
cd northwind

dbt deps      # baixa pacotes auxiliares (dbt_utils, dbt_expectations, dbt_date)
dbt seed      # não há seeds no momento, mas o comando é opcional

dbt run       # materializa os modelos raw, staging e gold
dbt test      # valida os dados conforme testes definidos
```

Os modelos são materializados em schemas distintos (`raw`, `silver`, `gold`) graças à macro `generate_schema_name`. Ajuste o `target.schema` no `profiles.yml` para controlar o namespace base.

## Estrutura do projeto

```
.
├── README.md              # Este guia
├── northwind/             # Projeto dbt
│   ├── dbt_project.yml    # Configuração principal do dbt
│   ├── models/
│   │   ├── raw/           # Modelos "bronze"
│   │   ├── staging/       # Modelos "silver"
│   │   └── reports/       # Modelos "gold"
│   ├── macros/            # Macros personalizadas
│   ├── analyses/, seeds/, snapshots/, tests/
│   └── packages.yml       # Dependências de pacotes dbt
├── northwind.sql          # Dump SQL com o esquema operacional
├── pyproject.toml         # Metadados e dependências Python
└── uv.lock                # Lockfile gerado pelo uv (opcional)
```

## Modelos de destaque

- `raw_orders`, `raw_order_details`, `raw_customers`: espelham as tabelas originais do banco.
- `stg_order_details`: calcula `total_sales` a partir de `unit_price`, `quantity` e `discount`.
- `report_totalsales`: agrega pedidos por `order_id`, enriquece com dados de funcionários e expõe métricas de volume e valor.

## Próximos passos sugeridos

- Adicionar testes de dados (`schema.yml`) para garantir qualidade.
- Criar modelos adicionais (ex.: métricas por cliente e por categoria).
- Automatizar a atualização diária via agendador (Airflow, dbt Cloud, etc.).

## Recursos úteis

- [Documentação oficial do dbt](https://docs.getdbt.com/)
- [Pacote dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/)
- [dbt Expectations](https://hub.getdbt.com/metaplane/dbt_expectations/latest/)
- [Northwind sample database](https://github.com/pthom/northwind_psql)

