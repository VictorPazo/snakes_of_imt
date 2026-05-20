import torch
import torch.nn.functional as F
from torchvision import transforms, models
from PIL import Image
import json

# =========================
# CONFIG
# =========================
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

MODEL_PATH = "best_model_b3_v2.pth"

# Caminho da imagem para testar
IMAGE_PATH = r"C:\Users\AMD\OneDrive\Desktop\TCC\images.webp"

# =========================
# CLASSES
# =========================
with open("classes.json", "r") as f:
    class_names = json.load(f)

# =========================
# TRANSFORM
# =========================
transform = transforms.Compose([
    transforms.Resize((300, 300)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225]
    )
])

# =========================
# LOAD MODEL
# =========================
model = models.efficientnet_b3(pretrained=False)

model.classifier[1] = torch.nn.Linear(
    model.classifier[1].in_features,
    len(class_names)
)

model.load_state_dict(torch.load(MODEL_PATH, map_location=DEVICE))

model.to(DEVICE)
model.eval()

# =========================
# PREDICT IMAGE
# =========================
def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")

    image = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(image)

        probs = F.softmax(output, dim=1)

        top3_probs, top3_idx = torch.topk(probs, 3)

    print("\n===== RESULTADO =====")

    for i in range(3):
        classe = class_names[top3_idx[0][i].item()]
        confianca = top3_probs[0][i].item() * 100

        print(f"Top {i+1}: {classe} -> {confianca:.2f}%")

# =========================
# MAIN
# =========================
if __name__ == "__main__":
    predict_image(IMAGE_PATH)