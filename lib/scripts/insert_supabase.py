"""
Insere as espécies enriquecidas na tabela `snakes` do Supabase, pulando qualquer 'specie' que já exista no banco.
"""

import json
import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_SERVICE_KEY = os.environ["SUPABASE_SERVICE_KEY"]

supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

TABLE_NAME = "snakes"


def get_existing_species():
    """Retorna o conjunto de 'specie' já cadastrados no banco, para evitar duplicatas."""
    existing = set()
    page_size = 1000
    start = 0
    while True:
        resp = (
            supabase.table(TABLE_NAME)
            .select("specie")
            .range(start, start + page_size - 1)
            .execute()
        )
        rows = resp.data
        if not rows:
            break
        for r in rows:
            existing.add(r["specie"])
        if len(rows) < page_size:
            break
        start += page_size
    return existing


def insert_species(enriched_species, dry_run=True, batch_size=50):
    existing = get_existing_species()
    to_insert = [s for s in enriched_species if s["specie"] not in existing]

    print(f"Já existem no banco: {len(existing)}")
    print(f"Novas espécies a inserir: {len(to_insert)}")

    if dry_run:
        print("\n[DRY RUN] Nada foi inserido. Rode com dry_run=False para inserir de verdade.")
        return to_insert

    inserted = 0
    for i in range(0, len(to_insert), batch_size):
        batch = to_insert[i : i + batch_size]
        supabase.table(TABLE_NAME).insert(batch).execute()
        inserted += len(batch)
        print(f"Inserido: {inserted}/{len(to_insert)}")

    return to_insert


if __name__ == "__main__":
    genus = sys.argv[1] if len(sys.argv) > 1 else "Bothrops"
    input_file = f"snakes_enriched_{genus.lower()}.json"

    with open(input_file, "r", encoding="utf-8") as f:
        enriched = json.load(f)

    # ATENÇÃO: primeiro rode com dry_run=True para conferir o que será inserido.
    # Só mude para False depois de revisar manualmente os campos marcados "REVISAR"
    # no arquivo snakes_enriched_<genero>.json (especialmente venom_type e effective_antivenom).
    insert_species(enriched, dry_run=False)