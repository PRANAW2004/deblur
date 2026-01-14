from torch.utils.data import DataLoader
import torch.optim as optim
from tqdm import tqdm
import torch
import torch.nn as nn

device = "cuda" if torch.cuda.is_available() else "cpu"
print("device =", device)

torch.backends.cudnn.benchmark = True  # speed boost

train_dataset = GoProDataset(
    "/content/drive/MyDrive/Gopro/train/blur",
    "/content/drive/MyDrive/Gopro/train/sharp",
    patch_size=256  
)

train_loader = DataLoader(
    train_dataset,
    batch_size=2,      # SAFE for Colab
    shuffle=True,
    num_workers=2,
    pin_memory=True
)

model = UNet().to(device)
print("Model device:", next(model.parameters()).device)

criterion = nn.L1Loss()
optimizer = optim.Adam(model.parameters(), lr=1e-4)

scaler = torch.cuda.amp.GradScaler()  # mixed precision

epochs = 20

for epoch in range(epochs):
    model.train()
    total_loss = 0

    for blur, sharp in tqdm(train_loader):
        blur = blur.to(device, non_blocking=True)
        sharp = sharp.to(device, non_blocking=True)

        optimizer.zero_grad()

        # Mixed precision forward
        with torch.cuda.amp.autocast():
            pred = model(blur)
            loss = criterion(pred, sharp)

        # Backward safely
        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()

        total_loss += loss.item()

    print(f"Epoch {epoch+1}, Loss: {total_loss/len(train_loader):.6f}")
    torch.cuda.empty_cache()

torch.save(model.state_dict(), "deblur_unet.pth")

