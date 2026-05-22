import io
import json

from fastapi import FastAPI, UploadFile, File

import torch
import torch.nn.functional as F

from torchvision import transforms, models

from PIL import Image

# =========================
# APP
# =========================

app = FastAPI()

# =========================
# DEVICE
# =========================

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available()
    else "cpu"
)

# =========================
# LOAD CLASSES
# =========================

with open("classes.json", "r") as f:
    class_names = json.load(f)

# =========================
# CLASS -> DATABASE ID
# =========================

CLASS_TO_ID = {

    "Bothrops alcatraz": 1,
    "Bothrops alternatus": 2,
    "Bothrops atrox": 3,

    "Bothrops bilineatus": 4,
    "Bothrops brazili": 5,
    "Bothrops cotiara": 6,

    "Bothrops diporus": 7,
    "Bothrops erythromelas": 8,
    "Bothrops fonsecai": 9,

    "Bothrops insularis": 10,
    "Bothrops itapetiningae": 11,
    "Bothrops jabrensis": 12,

    "Bothrops jararaca": 13,
    "Bothrops jararacussu": 14,
    "Bothrops leucurus": 15,

    "Bothrops lutzi": 16,
    "Bothrops marajoensis": 17,
    "Bothrops marmoratus": 18,

    "Bothrops mattogrossensis": 19,
    "Bothrops moojeni": 20,
    "Bothrops muriciensis": 21,

    "Bothrops neuwiedi": 22,
    "Bothrops pauloensis": 23,
    "Bothrops pirajai": 24,

    "Bothrops pubescens": 25,
    "Bothrops taeniatus": 26,
}

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

model = models.efficientnet_b3(
    pretrained=False
)

model.classifier[1] = torch.nn.Linear(
    model.classifier[1].in_features,
    len(class_names)
)

model.load_state_dict(
    torch.load(
        "best_model_b3_v2.pth",
        map_location=DEVICE
    )
)

model.to(DEVICE)

model.eval()

# =========================
# PREDICT ENDPOINT
# =========================

@app.post("/predict")

async def predict(
        file: UploadFile = File(...)
):

    image_bytes = await file.read()

    image = Image.open(
        io.BytesIO(image_bytes)
    ).convert("RGB")

    image = transform(image)\
        .unsqueeze(0)\
        .to(DEVICE)

    with torch.no_grad():

        output = model(image)

        probs = F.softmax(output, dim=1)

        confidence, predicted = torch.max(probs, 1)

    predicted_class = class_names[
        predicted.item()
    ]

    snake_id = CLASS_TO_ID[
        predicted_class
    ]

    return {

        "snake_id": snake_id,

        "specie": predicted_class,

        "confidence":
        round(confidence.item() * 100, 2)
    }