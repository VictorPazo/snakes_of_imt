#########################
# AINDA EM TESTES #
#########################

import torch
import torch.nn.functional as F
from torchvision import transforms, models
from PIL import Image

# =========================
# CONFIG
# =========================
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ⚠️ IMPORTANTE: mesmas classes do treino
class_names = [
    "classe1",
    "classe2",
    "classe3"
]

# =========================
# TRANSFORM (igual ao treino)
# =========================
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

# =========================
# LOAD MODEL
# =========================
model = models.efficientnet_b0(pretrained=False)
model.classifier[1] = torch.nn.Linear(
    model.classifier[1].in_features,
    len(class_names)
)

model.load_state_dict(torch.load("best_model.pth", map_location=DEVICE))
model.to(DEVICE)
model.eval()

# =========================
# FUNÇÃO DE PREVISÃO
# =========================
def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")
    image = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(image)
        probs = F.softmax(output, dim=1)

        top_prob, top_idx = torch.max(probs, dim=1)

    classe = class_names[top_idx.item()]
    confianca = top_prob.item() * 100

    return classe, confianca

# =========================
# TESTE
# =========================
if __name__ == "__main__":
    path = "teste.jpg"  # coloque o caminho da imagem aqui

    classe, confianca = predict_image(path)

    print(f"Espécie: {classe}")
    print(f"Confiança: {confianca:.2f}%")