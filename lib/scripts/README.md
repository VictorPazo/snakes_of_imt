# Automação — popular banco `snakes` no Supabase

Pipeline em 3 passos para buscar todas as serpentes do Brasil (via GBIF),
enriquecer com os campos da tabela, e inserir no Supabase evitando duplicatas.

## Setup

```bash
cd lib/scripts
pip install -r requirements.txt
# edite o .env e coloque sua SUPABASE_URL e SUPABASE_SERVICE_KEY
# (pegue a service_role key em: Project Settings > API > service_role secret)
```

O pipeline roda **um gênero por vez** (ex: `Crotalus`, `Micrurus`), o que
facilita revisar os resultados antes de seguir para o próximo. Troque
`Crotalus` pelo gênero desejado em cada comando abaixo.

## Passo 1 — Buscar espécies no GBIF

```bash
python fetch_gbif.py Crotalus
```

Gera `gbif_crotalus_raw.json` com as espécies desse gênero com ocorrência
registrada no Brasil (family, genus, specie), direto da API pública do GBIF.

## Passo 2 — Enriquecer com as regras da tabela

```bash
python enrich.py Crotalus
```

Gera `snakes_enriched_crotalus.json` já no formato da tabela `snakes`, aplicando regras conhecidas por família:

| Campo | Como é preenchido |

| `family`, `genus`, `specie` | Direto do GBIF |
| `dentition_type`            | Regra por família (Viperidae→Solenóglifa, Elapidae→Proteróglifa...) |
| `poisonous`                 | Regra por família (Viperidae e Elapidae = `true`) |
| `image_name`                | Gerado no padrão `genero_especie.jpg` |
| `description`, `venom_type`, `effective_antivenom` | Marcados como `"REVISAR"` |

⚠️ **Antes de seguir para o passo 3**, abra o `snakes_enriched_crotalus.json` e
revise manualmente os campos `"REVISAR"`.

## Passo 3 — Inserir no Supabase

```bash
python insert_supabase.py Crotalus
```

Depois de revisar os dados, abra `insert_supabase.py` e mude
`dry_run=True` para `dry_run=False` na última linha para inserir de verdade.

## Repetindo para outros gêneros

Depois de validar com `Crotalus`, é só repetir os 3 passos trocando o nome
do gênero, ex: `Micrurus`, `Lachesis`, `Boa`, `Epicrates`, etc.