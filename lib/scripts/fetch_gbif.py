"""
Busca todas as espécies de um GÊNERO de serpente com ocorrência registrada
no Brasil, usando a API pública do GBIF (sem necessidade de chave).

Uso:
    python fetch_gbif.py Crotalus

Se nenhum gênero for passado, usa "Bothrops" como padrão.

Por que por gênero e não pelo suborder inteiro (Serpentes)?
O GBIF Backbone às vezes resolve nomes de rank alto (suborder, ordem) para
um nó "alternativo" da árvore taxonômica com poucos registros vinculados,
mesmo com matchType=EXACT. Nomes de GÊNERO são resolvidos de forma bem mais
confiável, então essa é a abordagem recomendada aqui.
"""

import requests
import time
import json
import sys

SPECIES_MATCH_URL = "https://api.gbif.org/v1/species/match"
OCCURRENCE_SEARCH_URL = "https://api.gbif.org/v1/occurrence/search"
SPECIES_URL = "https://api.gbif.org/v1/species/{}"


def get_taxon_key(name, rank):
    """Resolve o taxonKey do GBIF Backbone para um nome + rank (ex: 'Bothrops', 'GENUS')."""
    resp = requests.get(
        SPECIES_MATCH_URL,
        params={"name": name, "rank": rank, "strict": True},
        timeout=30,
    )
    resp.raise_for_status()
    data = resp.json()
    key = data.get("usageKey")

    print(f"[debug] {name} ({rank}) -> taxonKey={key} | matchType={data.get('matchType')} "
          f"| status={data.get('status')} | rank_retornado={data.get('rank')}")

    if not key:
        raise RuntimeError(f"Não foi possível resolver '{name}' ({rank}) no GBIF: {data}")
    return key


def sanity_check_occurrence_count(taxon_key, country=None):
    """Só pra debug: mostra quantas ocorrências existem pra essa chave,
    com e sem filtro de país, ajuda a perceber se a chave resolvida faz sentido."""
    params = {"taxonKey": taxon_key, "limit": 0}
    if country:
        params["country"] = country
    resp = requests.get(OCCURRENCE_SEARCH_URL, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json().get("count", 0)


def fetch_species_keys_for_taxon(taxon_key, country="BR", facet_limit=1200):
    params = {
        "taxonKey": taxon_key,
        "country": country,
        "limit": 0,
        "facet": "speciesKey",
        "facetLimit": facet_limit,
    }
    resp = requests.get(OCCURRENCE_SEARCH_URL, params=params, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    facets = data.get("facets", [])
    species_facet = next((f for f in facets if f.get("field") == "SPECIES_KEY"), None)
    if not species_facet:
        return []

    return [int(c["name"]) for c in species_facet["counts"]]


def fetch_species_details(species_key):
    resp = requests.get(SPECIES_URL.format(species_key), timeout=30)
    resp.raise_for_status()
    data = resp.json()
    return {
        "family": data.get("family"),
        "genus": data.get("genus"),
        "specie": data.get("species") or data.get("canonicalName"),
        "gbif_key": species_key,
    }


def fetch_species_for_genus(genus_name, country="BR"):
    genus_key = get_taxon_key(genus_name, "GENUS")

    total_no_filter = sanity_check_occurrence_count(genus_key)
    total_br = sanity_check_occurrence_count(genus_key, country=country)
    print(f"[debug] Ocorrências totais (mundo) para {genus_name}: {total_no_filter}")
    print(f"[debug] Ocorrências no Brasil para {genus_name}: {total_br}")

    species_keys = fetch_species_keys_for_taxon(genus_key, country=country)
    print(f"[debug] Espécies distintas encontradas no Brasil: {len(species_keys)}")

    species_list = []
    for key in species_keys:
        try:
            details = fetch_species_details(key)
        except requests.RequestException as e:
            print(f"[aviso] Falhou ao buscar detalhes da espécie {key}: {e}")
            continue

        if not details["specie"] or not details["genus"] or not details["family"]:
            continue

        species_list.append(details)
        time.sleep(0.1)

    # Remove duplicatas
    seen = set()
    unique = []
    for s in species_list:
        if s["specie"] not in seen:
            seen.add(s["specie"])
            unique.append(s)

    return unique


if __name__ == "__main__":
    genus = sys.argv[1] if len(sys.argv) > 1 else "Bothrops"

    print(f"Buscando espécies do gênero '{genus}' no Brasil...")
    species = fetch_species_for_genus(genus)
    print(f"Total de espécies únicas encontradas: {len(species)}")

    output_file = f"gbif_{genus.lower()}_raw.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(species, f, ensure_ascii=False, indent=2)

    print(f"Salvo em {output_file}")