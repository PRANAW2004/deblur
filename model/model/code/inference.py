import os
import io
import torch
import torchvision.transforms as T
from PIL import Image
from model import UNet

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def model_fn(model_dir):
    model = UNet().to(device)

    state_dict_path = os.path.join(model_dir, "deblur_unet.pth")
    state_dict = torch.load(state_dict_path, map_location=device)

    model.load_state_dict(state_dict)
    model.eval()
    return model


def input_fn(request_body, content_type):
    image = Image.open(io.BytesIO(request_body)).convert("RGB")
    tensor = T.ToTensor()(image).unsqueeze(0).to(device)
    return tensor


def predict_fn(inputs, model):
    with torch.no_grad():
        output = model(inputs)

    if not isinstance(output, torch.Tensor) or output.dim() != 4:
        raise RuntimeError(f"Invalid output: {type(output)} {getattr(output, 'shape', None)}")

    return output


def output_fn(prediction, accept):
    pred = prediction.squeeze(0).cpu()
    pred = pred.clamp(0, 1)

    image = T.ToPILImage()(pred)
    buf = io.BytesIO()
    image.save(buf, format="JPEG")

    return buf.getvalue()
