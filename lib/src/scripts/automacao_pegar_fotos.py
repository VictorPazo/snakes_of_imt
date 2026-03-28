import os
import requests
import time

# pasta base (onde estão suas espécies)
pasta_base = "serpentes"

# quantidade de imagens por espécie (limite)
MAX_IMAGENS = 20

# delay pra não tomar bloqueio
DELAY = 1


def baixar_imagens(especie):
    nome_busca = especie.replace(" ", "%20")

    url = f"https://api.inaturalist.org/v1/observations"
    params = {
        "q": especie,
        "quality_grade": "research",
        "photos": "true",
        "per_page": 50,
        "page": 1
    }

    pasta_especie = os.path.join(pasta_base, especie)
    os.makedirs(pasta_especie, exist_ok=True)

    total_baixadas = 0

    while total_baixadas < MAX_IMAGENS:
        response = requests.get(url, params=params)
        data = response.json()

        resultados = data.get("results", [])
        if not resultados:
            break

        for obs in resultados:
            for foto in obs.get("photos", []):
                if total_baixadas >= MAX_IMAGENS:
                    break

                img_url = foto["url"].replace("square", "original")

                try:
                    img_data = requests.get(img_url).content

                    nome_arquivo = f"{total_baixadas}.jpg"
                    caminho = os.path.join(pasta_especie, nome_arquivo)

                    with open(caminho, "wb") as f:
                        f.write(img_data)

                    total_baixadas += 1
                    print(f"{especie}: {total_baixadas}")

                    time.sleep(DELAY)

                except Exception as e:
                    print("Erro:", e)

        params["page"] += 1


# -------------------------
# Rodar para todas espécies
# -------------------------
for especie in os.listdir(pasta_base):
    caminho = os.path.join(pasta_base, especie)

    if os.path.isdir(caminho):
        print(f"\nBaixando: {especie}")
        baixar_imagens(especie)