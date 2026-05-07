import os
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import DataLoader, random_split, Dataset, WeightedRandomSampler
from torchvision import datasets, transforms, models
from PIL import Image
import matplotlib.pyplot as plt
from collections import Counter

# =========================
# CONFIG
# =========================
BATCH_SIZE = 16  # 🔥 menor por causa do B3
EPOCHS = 60
LR = 0.0001
PATIENCE = 5
IMG_SIZE = 300  # 🔥 importante pro B3

TRAIN_DIR = "C:\\Users\\AMD\\OneDrive\\Desktop\\TCC\\Bothrops"

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# =========================
# TRANSFORMS
# =========================

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(IMG_SIZE, scale=(0.7, 1.0)),
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

val_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

# =========================
# DATASET
# =========================
train_full = datasets.ImageFolder(TRAIN_DIR, transform=train_transform)

valid_labels = sorted(set([label for _, label in train_full.samples]))
num_classes = len(valid_labels)

print(f"Total de classes: {num_classes}")

valid_class_names = [train_full.classes[i] for i in valid_labels]

# =========================
# DATASET CUSTOM
# =========================
label_map = {old: new for new, old in enumerate(valid_labels)}

class FilteredDataset(Dataset):
    def __init__(self, dataset, label_map):
        self.dataset = dataset
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

filtered_dataset = FilteredDataset(train_full, label_map)

# =========================
# SPLIT
# =========================
train_size = int(0.8 * len(filtered_dataset))
val_size = len(filtered_dataset) - train_size

train_data, val_data = random_split(filtered_dataset, [train_size, val_size])

# 🔥 garantir transform correto na validação
val_data.dataset.dataset.transform = val_transform

# =========================
# SAMPLER
# =========================
train_labels = [filtered_dataset.samples[i][1] for i in train_data.indices]

class_count = Counter(train_labels)
weights = [1.0 / class_count[label] for label in train_labels]

sampler = WeightedRandomSampler(
    weights,
    num_samples=len(weights) * 3,
    replacement=True
)

train_loader = DataLoader(train_data, batch_size=BATCH_SIZE, sampler=sampler)
val_loader = DataLoader(val_data, batch_size=BATCH_SIZE)

# =========================
# MODEL (B3 🔥)
# =========================
model = models.efficientnet_b3(pretrained=True)

# 🔥 Fine-tuning (libera últimas camadas)
for param in model.features[:-3].parameters():
    param.requires_grad = False

model.classifier[1] = nn.Linear(
    model.classifier[1].in_features,
    num_classes
)

model = model.to(DEVICE)

# =========================
# LOSS & OPTIMIZER
# =========================
criterion = nn.CrossEntropyLoss(label_smoothing=0.1)

optimizer = optim.Adam(
    filter(lambda p: p.requires_grad, model.parameters()),
    lr=LR
)

scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
    optimizer,
    mode='min',
    patience=2,
    factor=0.5
)

# =========================
# TRAIN LOOP
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
    correct = 0
    total = 0

    with torch.no_grad():
        for images, labels in val_loader:
            images, labels = images.to(DEVICE), labels.to(DEVICE)

            outputs = model(images)
            loss = criterion(outputs, labels)
            val_loss += loss.item()

            preds = outputs.argmax(dim=1)
            correct += (preds == labels).sum().item()
            total += labels.size(0)

    val_loss /= len(val_loader)
    val_acc = correct / total
    val_losses.append(val_loss)

    scheduler.step(val_loss)

    print(f"Epoch {epoch+1}: Train Loss={train_loss:.4f} | Val Loss={val_loss:.4f} | Val Acc={val_acc:.4f}")

    # EARLY STOPPING
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        torch.save(model.state_dict(), "best_model_b3.pth")
    else:
        patience_counter += 1

    if patience_counter >= PATIENCE:
        print("⛔ Early stopping ativado")
        break

# =========================
# PLOT
# =========================
plt.plot(train_losses, label="Train Loss")
plt.plot(val_losses, label="Val Loss")
plt.legend()
plt.title("Training vs Validation Loss")
plt.show()

# =========================
# LOAD BEST MODEL
# =========================
model.load_state_dict(torch.load("best_model_b3.pth"))
model.eval()

# =========================
# PREDICT
# =========================
def predict_image(image_path):
    image = Image.open(image_path).convert("RGB")
    image = val_transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(image)
        probs = F.softmax(output, dim=1)
        top_probs, top_idxs = torch.topk(probs, 3)

    print("\nTop 3 previsões:")
    for prob, idx in zip(top_probs[0], top_idxs[0]):
        print(f"{valid_class_names[idx]}: {prob.item()*100:.2f}%")

# =========================
# TESTE
# =========================
if __name__ == "__main__":
    path = r"C:\Users\AMD\OneDrive\Desktop\TCC\teste.jpg"
    predict_image(path)