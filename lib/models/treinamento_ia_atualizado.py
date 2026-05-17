import os
import json
import random
import numpy as np

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import (
    DataLoader,
    Dataset,
    WeightedRandomSampler
)

from torchvision import datasets, transforms, models
from PIL import Image
import matplotlib.pyplot as plt
from collections import Counter

from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

SEED = 42

torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)
np.random.seed(SEED)
random.seed(SEED)

BATCH_SIZE = 16
EPOCHS     = 60
LR         = 3e-5
PATIENCE   = 7
IMG_SIZE   = 300

TRAIN_DIR = r"C:\Users\AMD\OneDrive\Desktop\TCC\Bothrops"

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Usando dispositivo: {DEVICE}")

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(IMG_SIZE, scale=(0.8, 1.0)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip(p=0.1),
    transforms.RandomRotation(15),
    transforms.RandomPerspective(distortion_scale=0.1, p=0.3),

    transforms.ColorJitter(
        brightness=0.3,
        contrast=0.2,
        saturation=0.2,
        hue=0.05
    ),

    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

val_transform = transforms.Compose([
    transforms.Resize(320),
    transforms.CenterCrop(IMG_SIZE),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

base_dataset = datasets.ImageFolder(TRAIN_DIR)

print(f"Total de imagens: {len(base_dataset)}")
print(f"Total de classes: {len(base_dataset.classes)}")
print(f"Classes: {base_dataset.classes}")

with open("classes.json", "w") as f:
    json.dump(base_dataset.classes, f)

print("✅ classes.json salvo!")

all_labels = [s[1] for s in base_dataset.samples]

train_indices, val_indices = train_test_split(
    range(len(base_dataset)),
    test_size=0.2,
    stratify=all_labels,
    random_state=SEED
)

print(f"\nTamanho treino:    {len(train_indices)} imagens")
print(f"Tamanho validação: {len(val_indices)} imagens")

# Verificar distribuição após split
train_label_dist = Counter(all_labels[i] for i in train_indices)
print("\nDistribuição por classe (treino):")
for cls_idx, count in sorted(train_label_dist.items()):
    print(f"  {base_dataset.classes[cls_idx]}: {count} imagens")

class CustomDataset(Dataset):

    def __init__(self, dataset, indices, transform):
        self.dataset   = dataset
        self.indices   = list(indices)
        self.transform = transform

    def __len__(self):
        return len(self.indices)

    def __getitem__(self, idx):
        real_idx = self.indices[idx]
        path, label = self.dataset.samples[real_idx]
        image = Image.open(path).convert("RGB")
        if self.transform:
            image = self.transform(image)
        return image, label


train_data = CustomDataset(base_dataset, train_indices, train_transform)
val_data   = CustomDataset(base_dataset, val_indices,   val_transform)

train_labels_list = [base_dataset.samples[i][1] for i in train_indices]

class_count = Counter(train_labels_list)

weights = [1.0 / class_count[label] for label in train_labels_list]

sampler = WeightedRandomSampler(
    weights,
    num_samples=len(weights),
    replacement=True
)


train_loader = DataLoader(
    train_data,
    batch_size=BATCH_SIZE,
    sampler=sampler
)

val_loader = DataLoader(
    val_data,
    batch_size=BATCH_SIZE,
    shuffle=False
)


model = models.efficientnet_b3(
    weights=models.EfficientNet_B3_Weights.DEFAULT
)


for param in model.features[:-4].parameters():
    param.requires_grad = False


in_features = model.classifier[1].in_features

model.classifier = nn.Sequential(
    nn.Dropout(0.4),
    nn.Linear(in_features, len(base_dataset.classes))
)

model = model.to(DEVICE)

total_params     = sum(p.numel() for p in model.parameters())
trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
print(f"\nParâmetros totais:     {total_params:,}")
print(f"Parâmetros treináveis: {trainable_params:,}")


criterion = nn.CrossEntropyLoss(label_smoothing=0.05)


optimizer = optim.Adam(
    filter(lambda p: p.requires_grad, model.parameters()),
    lr=LR
)


scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
    optimizer,
    mode='min',
    patience=4,        # era 2, agora 4
    factor=0.5,
    min_lr=1e-7        # evita LR zero
)


best_val_loss    = float("inf")
patience_counter = 0

train_losses     = []
val_losses       = []
train_accuracies = []
val_accuracies   = []

for epoch in range(EPOCHS):


    model.train()

    running_loss  = 0
    train_correct = 0
    train_total   = 0

    for images, labels in train_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        outputs = model(images)
        loss    = criterion(outputs, labels)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        running_loss  += loss.item()
        preds          = outputs.argmax(dim=1)
        train_correct += (preds == labels).sum().item()
        train_total   += labels.size(0)

    train_loss = running_loss / len(train_loader)
    train_acc  = train_correct / train_total

    train_losses.append(train_loss)
    train_accuracies.append(train_acc)


    model.eval()

    val_loss  = 0
    correct   = 0
    total     = 0

    with torch.no_grad():

        for images, labels in val_loader:

            images  = images.to(DEVICE)
            labels  = labels.to(DEVICE)
            outputs = model(images)
            loss    = criterion(outputs, labels)

            val_loss += loss.item()
            preds     = outputs.argmax(dim=1)
            correct  += (preds == labels).sum().item()
            total    += labels.size(0)

    val_loss /= len(val_loader)
    val_acc   = correct / total

    val_losses.append(val_loss)
    val_accuracies.append(val_acc)

    scheduler.step(val_loss)

    current_lr = optimizer.param_groups[0]['lr']

    print(
        f"Epoch {epoch+1:02d}/{EPOCHS} | "
        f"Train Loss: {train_loss:.4f} | "
        f"Train Acc: {train_acc:.4f} | "
        f"Val Loss: {val_loss:.4f} | "
        f"Val Acc: {val_acc:.4f} | "
        f"LR: {current_lr:.2e}"
    )


    if val_loss < best_val_loss:

        best_val_loss    = val_loss
        patience_counter = 0

        torch.save(model.state_dict(), "best_model_b3_v2.pth")
        print("  ✅ Melhor modelo salvo!")

    else:
        patience_counter += 1

    if patience_counter >= PATIENCE:
        print("⛔ Early stopping ativado")
        break

# =========================
# PLOT LOSS
# =========================
plt.figure(figsize=(10, 5))
plt.plot(train_losses, label="Train Loss")
plt.plot(val_losses,   label="Val Loss")
plt.legend()
plt.title("Training vs Validation Loss")
plt.xlabel("Época")
plt.ylabel("Loss")
plt.tight_layout()
plt.savefig("loss_curve.png", dpi=150)
plt.show()

# =========================
# PLOT ACCURACY
# =========================
plt.figure(figsize=(10, 5))
plt.plot(train_accuracies, label="Train Accuracy")
plt.plot(val_accuracies,   label="Val Accuracy")
plt.legend()
plt.title("Training vs Validation Accuracy")
plt.xlabel("Época")
plt.ylabel("Acurácia")
plt.tight_layout()
plt.savefig("accuracy_curve.png", dpi=150)
plt.show()

# =========================
# ✅ MATRIZ DE CONFUSÃO
# =========================
print("\nGerando matriz de confusão...")

model.load_state_dict(torch.load("best_model_b3_v2.pth"))
model.eval()

all_preds  = []
all_labels = []

with torch.no_grad():
    for images, labels in val_loader:
        outputs     = model(images.to(DEVICE))
        preds       = outputs.argmax(dim=1).cpu().tolist()
        all_preds  += preds
        all_labels += labels.tolist()

cm = confusion_matrix(all_labels, all_preds)

disp = ConfusionMatrixDisplay(
    cm,
    display_labels=base_dataset.classes
)

fig, ax = plt.subplots(figsize=(14, 12))
disp.plot(ax=ax, xticks_rotation=45, colorbar=True)
plt.title("Matriz de Confusão — Validação")
plt.tight_layout()
plt.savefig("confusion_matrix.png", dpi=150)
plt.show()

# Acurácia por classe
print("\nAcurácia por espécie:")
for i, cls in enumerate(base_dataset.classes):
    cls_mask  = [l == i for l in all_labels]
    cls_preds = [p for p, m in zip(all_preds, cls_mask) if m]
    cls_true  = [l for l, m in zip(all_labels, cls_mask) if m]
    if len(cls_true) > 0:
        acc = sum(p == l for p, l in zip(cls_preds, cls_true)) / len(cls_true)
        print(f"  {cls}: {acc:.2%} ({len(cls_true)} amostras)")

print("\n✅ Treinamento finalizado!")
print(f"   Melhor val_loss: {best_val_loss:.4f}")
print("   Gráficos salvos: loss_curve.png, accuracy_curve.png, confusion_matrix.png")