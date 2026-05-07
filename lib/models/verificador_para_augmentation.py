import os

pasta_especies = "serpentes"

# extensões consideradas como imagem
extensoes_imagem = (".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp")

com_imagem = 0
sem_imagem = 0

lista_sem_imagem = []

def tem_imagem(caminho):
    for raiz, dirs, arquivos in os.walk(caminho):
        for arquivo in arquivos:
            if arquivo.lower().endswith(extensoes_imagem):
                return True
    return False

for especie in os.listdir(pasta_especies):

    caminho_especie = os.path.join(pasta_especies, especie)

    if not os.path.isdir(caminho_especie):
        continue

    if tem_imagem(caminho_especie):
        com_imagem += 1
    else:
        sem_imagem += 1
        lista_sem_imagem.append(especie)

print("\n===== RESULTADO =====")
print(f"Espécies com imagem: {com_imagem}")
print(f"Espécies sem imagem: {sem_imagem}")

print("\nEspécies sem imagem:")
for esp in lista_sem_imagem:
    print("-", esp)