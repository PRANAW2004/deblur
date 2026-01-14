import os
import cv2
import torch
import random
from torch.utils.data import Dataset


class GoProDataset(Dataset):
    def __init__(self, blur_dir, sharp_dir, patch_size=256):
        self.blur_paths = sorted([os.path.join(blur_dir, f) for f in os.listdir(blur_dir)])
        self.sharp_paths = sorted([os.path.join(sharp_dir, f) for f in os.listdir(sharp_dir)])
        self.patch_size = patch_size

    def __len__(self):
        return len(self.blur_paths)   # 👈 THIS IS REQUIRED

    def __getitem__(self, idx):
        blur = cv2.imread(self.blur_paths[idx])
        sharp = cv2.imread(self.sharp_paths[idx])

        blur = cv2.cvtColor(blur, cv2.COLOR_BGR2RGB) / 255.0
        sharp = cv2.cvtColor(sharp, cv2.COLOR_BGR2RGB) / 255.0

        h, w, _ = blur.shape
        ps = self.patch_size

        y = random.randint(0, h - ps)
        x = random.randint(0, w - ps)

        blur = blur[y:y+ps, x:x+ps]
        sharp = sharp[y:y+ps, x:x+ps]

        blur = torch.tensor(blur).permute(2,0,1).float()
        sharp = torch.tensor(sharp).permute(2,0,1).float()

        return blur, sharp
