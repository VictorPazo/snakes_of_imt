import os
import random
import torch
from PIL import Image
from torchvision import transforms


BASE_DIR = r"Seu_caminho_aqui"
TARGET_IMAGES = 100


# TRANSFORM

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(224, scale=(0.7, 1.0)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip(),
    transforms.RandomRotation(25),
    transforms.ColorJitter(
        brightness=0.3,
        contrast=0.3,
        saturation=0.3,
        hue=0.05
    ),
    transforms.RandomGrayscale(p=0.1),
    transforms.GaussianBlur(kernel_size=3),

    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

# DESNORMALIZAR
def denormalize(tensor):
    mean = torch.tensor([0.485, 0.456, 0.406]).view(3,1,1)
    std = torch.tensor([0.229, 0.224, 0.225]).view(3,1,1)
    return tensor * std + mean

to_pil = transforms.ToPILImage()

# PROCESSAMENTO
for especie in os.listdir(BASE_DIR):
    especie_path = os.path.join(BASE_DIR, especie)

    if not os.path.isdir(especie_path):
        continue

    imagens = [img for img in os.listdir(especie_path)
               if img.lower().endswith((".jpg", ".jpeg", ".png"))]

    total = len(imagens)
    print(f"\n📂 {especie} → {total} imagens")

    if total >= TARGET_IMAGES:
        print("✅ Já tem o suficiente")
        continue

    faltam = TARGET_IMAGES - total
    print(f"⚠️ Faltam {faltam} imagens (gerando augmentation...)")

    count = 0

    while count < faltam:
        img_name = random.choice(imagens)
        img_path = os.path.join(especie_path, img_name)

        try:
            image = Image.open(img_path).convert("RGB")

            # aplica augment
            tensor_img = train_transform(image)

            # desfaz normalize
            tensor_img = denormalize(tensor_img).clamp(0, 1)

            # volta pra imagem
            aug_img = to_pil(tensor_img)

            new_name = f"aug_{count}_{img_name}"
            new_path = os.path.join(especie_path, new_name)

            aug_img.save(new_path)

            count += 1

        except Exception as e:
            print(f"Erro com {img_name}: {e}")

    print(f"✅ {faltam} imagens geradas")