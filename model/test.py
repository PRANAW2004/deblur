import torch
import torch.nn as nn

class Dummy(nn.Module):
    def forward(self, x):
        return x.clamp(0, 1)

model = Dummy()
torch.save(model, "model.pth")
