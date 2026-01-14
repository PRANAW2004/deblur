import torch
import cv2
import numpy as np
from model import UNet
import matplotlib.pyplot as plt

def deblur_image(model, img_path, device):
    model.eval()

    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = img / 255.0

    x = torch.tensor(img).permute(2, 0, 1).unsqueeze(0).float().to(device)

    with torch.no_grad():
        pred = model(x)

    out = pred.squeeze().permute(1, 2, 0).cpu().numpy()
    out = (out * 255).clip(0, 255).astype(np.uint8)

    cv2.imwrite("output.png", cv2.cvtColor(out, cv2.COLOR_RGB2BGR))

    plt.imshow(out)
    plt.axis("off")
    plt.title("Deblurred Image")
    plt.show()
    print("Saved deblurred image as output.png")


if __name__ == "__main__":
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    model = UNet().to(device)
    model.load_state_dict(torch.load("deblur_unet.pth", map_location=device))

    deblur_image(model, "./Gopro/test/blur/1.png", device)
