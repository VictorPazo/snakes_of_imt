import os
import re
import shutil

arquivo_md = "Especies_Serpentes_BR.md"
pasta_dados = r"C:\\Users\\AMD\\OneDrive\\Desktop\\TCC\\SnakeCLEF2022-small_size"
pasta_especies = "serpentes"
pasta_fora = "fora_lista"

os.makedirs(pasta_fora, exist_ok=True)
especies = set()

with open(arquivo_md, "r", encoding="utf-8") as f:
    for linha in f:
        linha = linha.strip()

        match = re.match(r"^[A-Z][a-z]+\s[a-z]+", linha)
        if match:
            especies.add(match.group(0))

print("Espécies carregadas:", len(especies))



for ano in os.listdir(pasta_dados):

    caminho_ano = os.path.join(pasta_dados, ano)

    if not os.path.isdir(caminho_ano):
        continue

    for especie_pasta in os.listdir(caminho_ano):

        caminho_especie = os.path.join(caminho_ano, especie_pasta)

        if not os.path.isdir(caminho_especie):
            continue

        especie_nome = especie_pasta.replace("_", " ").strip()
        
        if especie_nome in especies:

            destino_base = os.path.join(pasta_especies, especie_nome)

            os.makedirs(destino_base, exist_ok=True)

            destino = os.path.join(destino_base, ano)

            if os.path.exists(destino):
                destino = destino + "_dup"

            shutil.move(caminho_especie, destino)

            print(f"Movida para espécie: {caminho_especie} → {destino}")

        else:           
            destino_ano = os.path.join(pasta_fora, ano)
            os.makedirs(destino_ano, exist_ok=True)

            destino = os.path.join(destino_ano, especie_pasta)

            if os.path.exists(destino):
                destino = destino + "_dup"

            shutil.move(caminho_especie, destino)

            print(f"Fora da lista: {caminho_especie} → {destino}")