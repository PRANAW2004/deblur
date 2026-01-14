from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.metrics import structural_similarity as ssim
import cv2
import imutils

# Read images
gt = cv2.imread("./Gopro/test/blur/1.png")
pred = cv2.imread("output.png")

# Convert to RGB (OpenCV reads as BGR)
gt = cv2.cvtColor(gt, cv2.COLOR_BGR2RGB)
pred = cv2.cvtColor(pred, cv2.COLOR_BGR2RGB)

# Optional: resize images if shapes don't match
if gt.shape != pred.shape:
    
    pred = cv2.resize(pred, (gt.shape[1], gt.shape[0]))

# PSNR
psnr_value = psnr(gt, pred)

# SSIM
ssim_value = ssim(gt, pred, channel_axis=-1)  # use channel_axis instead of multichannel

print("PSNR:", psnr_value)
print("SSIM:", ssim_value)
