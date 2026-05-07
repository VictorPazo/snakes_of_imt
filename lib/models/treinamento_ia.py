# 🐍 Snake Species Classification with EfficientNet (PyTorch)

import os
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import DataLoader, random_split, Dataset
from torchvision import datasets, transforms, models
from PIL import Image
import matplotlib.pyplot as plt

# =========================
# CONFIG
# =========================
BATCH_SIZE = 32
EPOCHS = 30
LR = 0.001
PATIENCE = 5

TRAIN_DIR = "/content/drive/MyDrive/TCC/serpentes"
TEST_DIR = "/content/drive/MyDrive/TCC/SnakeCLEF2022-test_images/SnakeCLEF2022-large_size"

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# =========================
# TRANSFORMS
# =========================
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(15),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

# =========================
# DATASET ORIGINAL
# =========================
train_full = datasets.ImageFolder(
    TRAIN_DIR,
    transform=transform,
    allow_empty=True
)

# =========================
# FILTRAR CLASSES VÁLIDAS
# =========================
valid_labels = sorted(set([label for _, label in train_full.samples]))
num_classes = len(valid_labels)

print(f"Total de classes (incluindo vazias): {len(train_full.classes)}")
print(f"Classes com imagens: {num_classes}")

# nomes das classes válidas
valid_class_names = [train_full.classes[i] for i in valid_labels]

# =========================
# REMAPEAR LABELS
# =========================
label_map = {old_label: new_label for new_label, old_label in enumerate(valid_labels)}

class FilteredDataset(Dataset):
    def __init__(self, dataset, label_map):
        self.dataset = dataset
        self.label_map = label_map

        self.samples = [
            (path, label_map[label])
            for path, label in dataset.samples
            if label in label_map
        ]

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        path, label = self.samples[idx]
        image = self.dataset.loader(path)

        if self.dataset.transform:
            image = self.dataset.transform(image)

        return image, label

# dataset limpo
filtered_dataset = FilteredDataset(train_full, label_map)

# =========================
# SPLIT
# =========================
train_size = int(0.8 * len(filtered_dataset))
val_size = len(filtered_dataset) - train_size

train_data, val_data = random_split(filtered_dataset, [train_size, val_size])

train_loader = DataLoader(train_data, batch_size=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_data, batch_size=BATCH_SIZE)

# =========================
# TEST DATASET (sem label)
# =========================
class TestDataset(Dataset):
    def __init__(self, folder, transform=None):
        self.folder = folder
        self.images = os.listdir(folder)
        self.transform = transform

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):
        img_name = self.images[idx]
        img_path = os.path.join(self.folder, img_name)
        image = Image.open(img_path).convert("RGB")

        if self.transform:
            image = self.transform(image)

        return image, img_name

test_data = TestDataset(TEST_DIR, transform=transform)
test_loader = DataLoader(test_data, batch_size=BATCH_SIZE)

# =========================
# MODEL
# =========================
model = models.efficientnet_b0(pretrained=True)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
model = model.to(DEVICE)

# =========================
# LOSS & OPTIMIZER
# =========================
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=LR)

# =========================
# TRAIN LOOP + EARLY STOPPING
# =========================
best_val_loss = float('inf')
patience_counter = 0

train_losses = []
val_losses = []

for epoch in range(EPOCHS):
    model.train()
    running_loss = 0

    for images, labels in train_loader:
        images, labels = images.to(DEVICE), labels.to(DEVICE)

        outputs = model(images)
        loss = criterion(outputs, labels)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        running_loss += loss.item()

    train_loss = running_loss / len(train_loader)
    train_losses.append(train_loss)

    # VALIDATION
    model.eval()
    val_loss = 0

    with torch.no_grad():
        for images, labels in val_loader:
            images, labels = images.to(DEVICE), labels.to(DEVICE)
            outputs = model(images)
            loss = criterion(outputs, labels)
            val_loss += loss.item()

    val_loss /= len(val_loader)
    val_losses.append(val_loss)

    print(f"Epoch {epoch+1}: Train Loss={train_loss:.4f} | Val Loss={val_loss:.4f}")

    # EARLY STOPPING
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        torch.save(model.state_dict(), "best_model.pth")
    else:
        patience_counter += 1

    if patience_counter >= PATIENCE:
        print("⛔ Early stopping ativado")
        break

# =========================
# PLOT LOSS
# =========================
plt.plot(train_losses, label="Train Loss")
plt.plot(val_losses, label="Val Loss")
plt.legend()
plt.title("Training vs Validation Loss")
plt.show()

# =========================
# LOAD BEST MODEL
# =========================
model.load_state_dict(torch.load("best_model.pth"))
model.eval()

# =========================
# PREDIÇÃO
# =========================
def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")
    image = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(image)
        probs = F.softmax(output, dim=1)

        top_probs, top_idxs = torch.topk(probs, 3)

    print("Top 3 previsões:")
    for prob, idx in zip(top_probs[0], top_idxs[0]):
        print(f"{valid_class_names[idx]}: {prob.item()*100:.2f}%")

# =========================
# TEST SET
# =========================
predictions = []

with torch.no_grad():
    for images, names in test_loader:
        images = images.to(DEVICE)
        outputs = model(images)
        probs = F.softmax(outputs, dim=1)

        top_probs, top_idxs = torch.max(probs, dim=1)

        for name, prob, idx in zip(names, top_probs, top_idxs):
            predictions.append((name, valid_class_names[idx], prob.item()*100))

# salvar resultados
import pandas as pd

df = pd.DataFrame(predictions, columns=["image", "prediction", "confidence"])
df.to_csv("predictions.csv", index=False)

print("✅ Predições salvas em predictions.csv")