# EE5351 Team Project Color Mapping

## CUDA Starter
Learning CUDA parallel programming.  To start, enable nvcc compiler driver as Stephen Smith suggests in his article[1].

> nvcc version 10.2

<img width="400" alt="Screenshot 2026-09-13 at 4 57 44 PM" src="https://github.com/user-attachments/assets/bbf94010-fd45-40d6-91f1-b06fd10fe410" />

## BPN 
Original Back propagation neural network (1 hidden layer) for color mapping from 1996.
It was written to run on a CPU. 
Training generally took 4+ hours.

## Test 
Generates bitmap test images: R, G, B, Gray 256 x 1
   
## RGBInputs 
1. Generates a raw binary from (0,0,0) -> (25,25,25); input look up table.
2. Reads a raw binary destination look up table.
3. Loads a specified bitmap for image processing.
4. Call device function, call kernel.
5. Save bitmap to file as 'processed.bmp'

## UnifiedMem 
Clone of RGBInputs project with use of UnifiedMemory

## PinnedMem
Clone of RGBInputs project with use of PinnedMem

> ./rgb snail.bmp
<img width="400" alt="Screenshot 2026-11-15 at 6 11 43 PM" src="https://github.com/user-attachments/assets/18fca256-2c46-45fd-9bcc-7e1fd498622b" />

# Reference
1. Stephen Smith's Blog, Playing with CUDA on My NVIDIA Jetson Nano, June 20, 2020
https://smist08.wordpress.com/2019/04/03/playing-with-cuda-on-my-nvidia-jetson-nano/

2. NNC Color Mapping \
https://library.imaging.org/cic/articles/1/1/art00010

3. Variable Rectilinear interpolation \
https://www.imaging.org/common/uploaded%20files/pdfs/Papers/1998/RP-0-69/2210.pdf

4. TIFF Target C++ code \
https://github.com/yeuchi/ColorVolumeTargets

5. Colorbration - color space conversions
https://github.com/yeuchi/colorbration/tree/master/android

