import torch
import os
import torch.nn.functional as F
from torchvision import transforms, models
from PIL import Image
from collections import defaultdict
import pandas as pd
import json

# =========================
# CONFIG
# =========================
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

PASTA_TREINO = r"C:\Users\AMD\OneDrive\Desktop\TCC\Bothrops"
PASTA_TESTE = r"C:\Users\AMD\OneDrive\Desktop\TCC\teste inicial"
MODEL_PATH = "best_model_b3.pth"

# ⚠️ IMPORTANTE: mesma ordem do treino
with open("classes.json", "r") as f:
    class_names = json.load(f)

transform = transforms.Compose([
    transforms.Resize((300, 300)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])


model = models.efficientnet_b3(pretrained=False)
model.classifier[1] = torch.nn.Linear(
    model.classifier[1].in_features,
    len(class_names)
)

model.load_state_dict(torch.load(MODEL_PATH, map_location=DEVICE))
model.to(DEVICE)
model.eval()

def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")
    image = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(image)
        probs = F.softmax(output, dim=1)
        top_prob, top_idx = torch.max(probs, dim=1)

    classe = class_names[top_idx.item()]
    confianca = top_prob.item() * 100

    return classe, confianca, probs


def avaliar_modelo():
    total_imagens = 0
    acertos_top1 = 0
    acertos_top3 = 0

    erros = []

    total_por_classe = defaultdict(int)
    acertos_por_classe = defaultdict(int)
    erros_por_classe = defaultdict(int)

    confusao = defaultdict(lambda: defaultdict(int))

    for especie_real in os.listdir(PASTA_TESTE):
        caminho_especie = os.path.join(PASTA_TESTE, especie_real)

        if not os.path.isdir(caminho_especie):
            continue

        for img_nome in os.listdir(caminho_especie):
            img_path = os.path.join(caminho_especie, img_nome)

            try:
                classe_pred, confianca, probs = predict_image(img_path)

                # TOP 3
                top3_probs, top3_idx = torch.topk(probs, 3)
                top3_classes = [class_names[i] for i in top3_idx[0]]

                total_imagens += 1
                total_por_classe[especie_real] += 1

                # TOP 1
                if classe_pred == especie_real:
                    acertos_top1 += 1
                    acertos_por_classe[especie_real] += 1
                else:
                    erros.append((img_nome, especie_real, classe_pred))
                    erros_por_classe[especie_real] += 1

                # matriz de confusão
                confusao[especie_real][classe_pred] += 1

                # TOP 3
                if especie_real in top3_classes:
                    acertos_top3 += 1

                print(f"[{total_imagens}] Real: {especie_real} | Pred: {classe_pred}")

            except Exception as e:
                print(f"Erro na imagem {img_nome}: {e}")

    print("\n===== RESULTADOS =====")
    print(f"Total de imagens: {total_imagens}")

    acc_top1 = (acertos_top1 / total_imagens * 100) if total_imagens > 0 else 0
    acc_top3 = (acertos_top3 / total_imagens * 100) if total_imagens > 0 else 0

    print(f"Accuracy Top-1: {acc_top1:.2f}%")
    print(f"Accuracy Top-3: {acc_top3:.2f}%")

    print(f"\nTotal de erros: {len(erros)}")

    print("\nExemplos de erros:")
    for e in erros[:10]:
        print(f"Imagem: {e[0]} | Real: {e[1]} | Predito: {e[2]}")


    dados_especies = []

    for especie in total_por_classe:
        total = total_por_classe[especie]
        acertos = acertos_por_classe[especie]
        erros_c = erros_por_classe[especie]

        acc = (acertos / total) * 100 if total > 0 else 0
        erro_rate = (erros_c / total) * 100 if total > 0 else 0

        dados_especies.append({
            "especie": especie,
            "total": total,
            "acertos": acertos,
            "erros": erros_c,
            "accuracy (%)": acc,
            "taxa_erro (%)": erro_rate
        })

    df_especies = pd.DataFrame(dados_especies)
    df_especies.to_csv("desempenho_por_especie.csv", index=False)
    print("✅ CSV salvo: desempenho_por_especie.csv")


    dados_confusao = []

    for real in confusao:
        for pred in confusao[real]:
            dados_confusao.append({
                "real": real,
                "predito": pred,
                "quantidade": confusao[real][pred]
            })

    df_confusao = pd.DataFrame(dados_confusao)
    df_confusao.to_csv("matriz_confusao.csv", index=False)
    print("✅ CSV salvo: matriz_confusao.csv")

    df_erros = pd.DataFrame(erros, columns=["imagem", "real", "predito"])
    df_erros.to_csv("erros.csv", index=False)
    print("✅ CSV salvo: erros.csv")

if __name__ == "__main__":
    avaliar_modelo()