import os
import re

# Caminho do arquivo .md
arquivo_md = "Especies_Serpentes_BR.md"

# Pasta onde tudo será criado
pasta_base = "serpentes"
os.makedirs(pasta_base, exist_ok=True)

def nome_valido(linha):
    linha = linha.strip()

    # Ignorar linhas vazias ou títulos
    if not linha:
        return False
    if linha.startswith("#"):
        return False
    if linha.startswith("**"):
        return False

    # Ignorar linhas com apenas uma letra (tipo "A", "B", etc.)
    if len(linha) == 1:
        return False

    return True

with open(arquivo_md, "r", encoding="utf-8") as f:
    for linha in f:
        linha = linha.strip()

        if not nome_valido(linha):
            continue

        # Remove textos entre parênteses
        linha = re.sub(r"\(.*?\)", "", linha).strip()

        # Remove caracteres problemáticos
        nome_pasta = linha.replace("/", "-")

        # Caminho final
        caminho = os.path.join(pasta_base, nome_pasta)

        try:
            os.makedirs(caminho, exist_ok=True)
        except Exception as e:
            print(f"Erro ao criar: {nome_pasta} -> {e}")

print("Pastas criadas com sucesso!")