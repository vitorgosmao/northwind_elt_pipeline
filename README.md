# 📊 Northwind ELT Pipeline

Um pipeline de Engenharia de Dados (ELT) que extrai dados do banco **Northwind**, transforma e carrega em três camadas de dados tratados utilizando **dbt (data build tool)**.

---

## 📋 Visão Geral

Este projeto implementa um pipeline ELT completo com as seguintes características:

- **Fonte de dados**: Base de dados Northwind (PostgreSQL)
- **Ferramenta de transformação**: dbt (Data Build Tool)
- **Infraestrutura**: Docker Compose para fácil deploy
- **Arquitetura em 3 camadas**: Staging → Analytics → Mart
- **Objetivo**: Preparar dados para análise de negócios e BI

### 🎯 Objetivo do Projeto

Criar um ambiente reproduzível e escalável para:
1. **Extração**: Carregar dados brutos do banco Northwind
2. **Transformação**: Limpar, normalizar e estruturar dados em múltiplas camadas
3. **Carregamento**: Disponibilizar dados tratados para análise e BI

---

## 🏗️ Arquitetura de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                  PostgreSQL (Northwind)                     │
│            (11 tabelas fonte de negócio)                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGING (stg_*)                                            │
│  • Limpeza e normalização básica                            │
│  • Renomeação de colunas padronizada                        │
│  • Validação de tipos de dados                              │
│  • Remoção de duplicatas e nulos                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  ANALYTICS (fct_*, dim_*)                                   │
│  • Modelos analíticos transformados                         │
│  • Estrutura dimensional/normalizada                        │
│  • Agregações e juncões de negócio                          │
│  • Pronto para análise exploratória                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Mart (mart_*)                                              │
│  • Métricas de negócio finais                               │
│  • Agregações e resumos prontos para BI                     │
│  • Otimizado para dashboards e relatórios                   │
│  • Consumível por ferramentas de visualização               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📚 Camadas de Dados

### 🔷 **Staging** (stg_*)
Primeira camada de transformação, responsável por:
- Cópia bruta das tabelas com limpeza inicial
- Renomeação padronizada de colunas (snake_case)
- Correção de tipos de dados e formatos
- Remoção de duplicatas e registros inválidos
- Documentação de campos e definição de testes em YAML
- Relações de integridade e qualidade declaradas em `models/staging/staging.yml`

**Materialização**: VIEW (rápida, sem duplicação)

### 🔶 **Analytics** (fct_*, dim_*)
Segunda camada, onde dados são transformados em estruturas analíticas:
- **Fact tables** (fct_*): Tabelas de eventos e transações
  - `fct_orders`: Pedidos com métricas de vendas
  - `fct_order_items`: Itens de pedido com detalhes de produto
  
- **Dimension tables** (dim_*): Tabelas de contexto e atributos
  - `dim_customers`: Informações de clientes
  - `dim_products`: Catálogo de produtos
  - `dim_employees`: Dados de funcionários
  - E outras dimensões de contexto

**Materialização**: TABLE (materializado para performance)

### 🟡 **Mart** (mart_*)
Terceira camada, contendo métricas finais prontas para BI:
- Agregações por período (vendas mensais, anuais)
- KPIs de negócio (receita, crescimento, retenção)
- Análises por segmento (clientes, produtos, regiões)
- Resumos para dashboards e relatórios executivos

**Materialização**: TABLE (otimizado para consultas rápidas)

---

## 🗂️ Tabelas-Fonte do Northwind

O banco de dados Northwind contém 11 tabelas principais que alimentam o pipeline:

| # | Tabela | Descrição | Registros Aprox. | Papel |
|---|--------|-----------|-----------------|------|
| 1 | **orders** | Pedidos realizados | ~800 | Principal (fact) |
| 2 | **order_details** | Itens dentro dos pedidos | ~2.600 | Principal (fact) |
| 3 | **customers** | Informações de clientes | ~90 | Dimensão |
| 4 | **products** | Catálogo de produtos | ~77 | Dimensão |
| 5 | **employees** | Dados de funcionários | ~9 | Dimensão |
| 6 | **categories** | Categorias de produtos | ~8 | Dimensão |
| 7 | **suppliers** | Fornecedores | ~29 | Dimensão |
| 8 | **territories** | Regiões de vendas | ~53 | Dimensão |
| 9 | **employee_territories** | Atribuição de vendedores a regiões | ~49 | Associação |
| 10 | **region** | Regiões agrupadas | ~4 | Dimensão |
| 11 | **shippers** | Transportadoras | ~3 | Dimensão |

**Relacionamentos principais**:
- `orders` ← JOIN → `customers`, `employees`, `shippers`
- `order_details` ← JOIN → `orders`, `products`
- `products` ← JOIN → `suppliers`, `categories`
- `employees` ← JOIN → `employee_territories`, `territories`

---

## 🚀 Pré-requisitos

Para rodar este projeto, você precisa de:

- **Docker** e **Docker Compose** (v20.10+)
- **Python** (v3.8+)
- **dbt-core** (v1.5+) e **dbt-postgres** adapter
- **Git**

### Instalação de Dependências (Local)

```bash
# Criar ambiente virtual Python
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate

# Instalar dbt e dependências
pip install dbt-core dbt-postgres
```

---

## 🛠️ Setup e Execução

### 1️⃣ Iniciar a Infraestrutura (Docker)

```bash
# Na raiz do projeto
docker-compose up -d

# Verificar se o banco está rodando
docker ps  # Deve mostrar container "db" como "Up"
```

O banco de dados PostgreSQL será inicializado com:
- **Host**: localhost
- **Porta**: 5432
- **Database**: northwind
- **Usuário**: postgres
- **Senha**: postgres

### 2️⃣ Configurar dbt

Criar arquivo `~/.dbt/profiles.yml` (se não existir):

```yaml
northwind_dbt:
  outputs:
    dev:
      type: postgres
      host: localhost
      user: postgres
      password: postgres
      port: 5432
      dbname: northwind
      schema: public
      threads: 4
      keepalives_idle: 0

  target: dev
```

### 3️⃣ Validar Conexão com dbt

```bash
cd northwind_dbt

# Testar conexão
dbt debug

# Deve exibir: "Connection test: [✓ ok]"
```

### 4️⃣ Executar o Pipeline

```bash
# Dentro do diretório northwind_dbt/

# Rodar todos os modelos (staging → analytics → mart)
dbt run

# Rodar apenas modelos staging
dbt run --models tag:staging

# Rodar com teste de dados
dbt test

# Gerar documentação
dbt docs generate
dbt docs serve  # Abre documentação em http://localhost:8000
```

---

## 📁 Estrutura de Diretórios

```
northwind_elt_pipeline/
├── docker-compose.yml              # Configuração do banco PostgreSQL
├── northwind.sql                   # Script inicial de dados Northwind
├── README.md                       # Este arquivo
├── files/                          # Arquivos de suporte
├── logs/                           # Logs de execução
│
└── northwind_dbt/                  # Projeto dbt
    ├── dbt_project.yml             # Configuração do projeto dbt
    ├── README.md                   # Documentação técnica do dbt
    │
    ├── models/                     # Modelos SQL (transformações)
    │   ├── staging/                # Camada 1: Limpeza e normalização
    │   │   ├── sources.yml         # Definição das 11 fontes Northwind
    │   │   ├── staging.yml         # Documentação de modelos e testes do staging
    │   │   ├── stg_orders.sql
    │   │   ├── stg_customers.sql
    │   │   └── ... (outros stg_*)
    │   │
    │   ├── analytics/              # Camada 2: Transformações analíticas
    │   │   ├── fct_orders.sql
    │   │   ├── dim_customers.sql
    │   │   └── ... (fct_*, dim_*)
    │   │
    │   └── mart/                   # Camada 3: Métricas finais para BI
    │       ├── mart_sales_summary.sql
    │       ├── mart_customer_metrics.sql
    │       └── ... (mart_*)
    │
    ├── tests/                      # Testes de qualidade de dados
    │   └── (Testes genericidade e customizados)
    │
    ├── macros/                     # Macros reutilizáveis
    │   └── (Funções customizadas dbt)
    │
    ├── seeds/                      # Dados estáticos (lookup tables)
    │   └── (CSVs para seed)
    │
    ├── analyses/                   # Análises ad-hoc (não são modelos)
    │   └── (Queries exploratórias)
    │
    ├── snapshots/                  # Snapshots de dimensões (SCD)
    │   └── (Histórico de mudanças)
    │
    ├── target/                     # Artefatos compilados (gerado)
    │   ├── manifest.json
    │   ├── graph.gpickle
    │   └── semantic_manifest.json
    │
    └── logs/                       # Logs de execução dbt
```

---

## 📊 Fluxo de Desenvolvimento

### Ciclo de Trabalho Típico

1. **Adicionar modelo SQL** em `models/staging/`, `models/analytics/` ou `models/mart/`
2. **Definir testes** em `tests/` ou via YAML (properties)
3. **Rodar dbt**:
   ```bash
   dbt run --models +seu_modelo  # Compila modelo e dependências
   dbt test --models +seu_modelo # Executa testes
   ```
4. **Revisar resultados** no banco de dados
5. **Documentar** no arquivo `.yml` correspondente

### Comandos dbt Úteis

```bash
dbt compile              # Compila modelos sem rodar
dbt run                  # Roda todos os modelos
dbt test                 # Executa testes de dados
dbt snapshot             # Cria snapshot de dados históricos
dbt docs generate        # Gera documentação
dbt docs serve           # Abre documentação interativa
dbt freshness            # Verifica atualização das fontes
dbt debug                # Diagnostica problemas de conexão
dbt parse                # Valida sintaxe dos modelos
```

---

## 🎯 Roadmap

### ✅ Fase 1: Estrutura Base (Concluída)
- [x] Configuração do Docker Compose com PostgreSQL
- [x] Inicialização do projeto dbt
- [x] Mapeamento das 11 tabelas do Northwind (sources.yml)
- [x] Estrutura de diretórios (staging, analytics, mart)

### 📋 Fase 2: Camada Staging (Concluída)
- [x] Criar modelos `stg_*` para cada tabela
- [x] Definir limpeza e normalização básica
- [x] Documentar campos e validações em `models/staging/staging.yml`
- [x] Implementar testes de qualidade básicos (`unique`, `not_null`, `relationships`)
- [ ] EXTRA: Expandir cobertura de testes e modelos de dados adicionais
  - [ ] Adicionar testes de valores esperados (`accepted_values`)
  - [ ] Padronizar tipos de dados (datas, números, textos)
  - [x] Gerar documentação automática (`dbt docs`)

### 📋 Fase 3: Camada Analytics (Concluída)
- [x] Criar fact tables (`fct_orders`, `fct_order_items`)
- [x] Criar dimension tables (`dim_customers`, `dim_products`, `dim_employees`)
- [x] Implementar agregações por período
- [x] Testes de integridade referencial

### 📋 Fase 4: Marts (Concluída)
- [x] Criar métricas de vendas (`mart_sales_summary`)
- [x] Criar KPIs de clientes (`mart_customer_metrics`)
- [x] Criar análises por produto e região (`mart_product_performance` e `mart_sales_by_region`)
- [x] Otimizar para performance em BI

### 📋 Fase 5: Documentação e Testes (Em Andamento)
- [x] Documentação completa de modelos
- [x] Suite de testes abrangente
- [x] Snapshots para auditoria de dimensões

### 📋 Fase 6: BI e Visualização (Futuro)
- [ ] Integração com ferramentas de BI (Metabase, Superset)
- [ ] Dashboards iniciais
- [ ] Alertas de qualidade de dados

---

## 📖 Documentação Adicional

- [dbt Official Docs](https://docs.getdbt.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Northwind Database Info](https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/sql/linq/downloading-sample-databases)

---

## 🤝 Contribuindo

Para adicionar novos modelos ou melhorias:

1. Criar branch: `git checkout -b feature/novo-modelo`
2. Implementar no diretório apropriado (`staging/`, `analytics/`, `mart/`)
3. Adicionar testes e documentação
4. Rodar `dbt run && dbt test` localmente
5. Submeter pull request

---

## 📝 Licença

Este projeto é fornecido como exemplo educacional.

---

**Última atualização**: Junho de 2026  
**Versão do projeto**: 1.0.0  
**Status**: Em desenvolvimento (Fase 2)