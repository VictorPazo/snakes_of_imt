import os
import re
import shutil

arquivo_md = "Especies_Serpentes_BR.md"

# pasta onde estão os dados (anos)
pasta_dados = r"C:\\Users\\AMD\\OneDrive\\Desktop\\TCC\\SnakeCLEF2022-small_size"

# pasta onde você criou as espécies (código anterior)
pasta_especies = "serpentes"

# fallback
pasta_fora = "fora_lista"

os.makedirs(pasta_fora, exist_ok=True)


# 1. Ler espécies do .md

especies = set()

with open(arquivo_md, "r", encoding="utf-8") as f:
    for linha in f:
        linha = linha.strip()

        # pega apenas "Genero especie"
        match = re.match(r"^[A-Z][a-z]+\s[a-z]+", linha)
        if match:
            especies.add(match.group(0))

print("Espécies carregadas:", len(especies))


# 2. Percorrer anos

for ano in os.listdir(pasta_dados):

    caminho_ano = os.path.join(pasta_dados, ano)

    if not os.path.isdir(caminho_ano):
        continue

    for especie_pasta in os.listdir(caminho_ano):

        caminho_especie = os.path.join(caminho_ano, especie_pasta)

        if not os.path.isdir(caminho_especie):
            continue

        especie_nome = especie_pasta.replace("_", " ").strip()

       
        # 3. DESTINO CORRETO
        
        if especie_nome in especies:

            destino_base = os.path.join(pasta_especies, especie_nome)

            # cria pasta da espécie se não existir
            os.makedirs(destino_base, exist_ok=True)

            destino = os.path.join(destino_base, ano)

            # evita erro de pasta duplicada
            if os.path.exists(destino):
                destino = destino + "_dup"

            shutil.move(caminho_especie, destino)

            print(f"Movida para espécie: {caminho_especie} → {destino}")

        else:
            
            # 4. FORA DA LISTA
           
            destino_ano = os.path.join(pasta_fora, ano)
            os.makedirs(destino_ano, exist_ok=True)

            destino = os.path.join(destino_ano, especie_pasta)

            if os.path.exists(destino):
                destino = destino + "_dup"

            shutil.move(caminho_especie, destino)

            print(f"Fora da lista: {caminho_especie} → {destino}")