import os
import re

arquivo_md = "Especies_Serpentes_BR.md"
pasta_base = "serpentes"
os.makedirs(pasta_base, exist_ok=True)

def nome_valido(linha):
    linha = linha.strip()
    if not linha:
        return False
    if linha.startswith("#"):
        return False
    if linha.startswith("**"):
        return False
    if len(linha) == 1:
        return False
    return True

with open(arquivo_md, "r", encoding="utf-8") as f:
    for linha in f:
        linha = linha.strip()
        if not nome_valido(linha):
            continue

        linha = re.sub(r"\(.*?\)", "", linha).strip()
        nome_pasta = linha.replace("/", "-")
        caminho = os.path.join(pasta_base, nome_pasta)

        try:
            os.makedirs(caminho, exist_ok=True)
        except Exception as e:
            print(f"Erro ao criar: {nome_pasta} -> {e}")

print("Pastas criadas com sucesso!")