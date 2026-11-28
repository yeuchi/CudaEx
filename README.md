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
> ./test
<img width="400" alt="Screenshot 2026-11-25 at 6 09 15 PM" src="https://github.com/user-attachments/assets/01d03fdc-9d2f-417c-9d79-410c27f604d4" />
   
## RGBInputs 
1. Generates a raw binary from (0,0,0) -> (25,25,25); input look up table.
2. Reads a raw binary destination look up table.
3. Loads a specified bitmap for image processing.
4. Call device function, call kernel.
5. Save bitmap to file as 'processed.bmp'

> ./rgb snail.bmp
<img width="400" alt="Screenshot 2026-11-15 at 6 11 43 PM" src="https://github.com/user-attachments/assets/18fca256-2c46-45fd-9bcc-7e1fd498622b" />

## UnifiedMem 
Clone of RGBInputs project with use of UnifiedMemory
Changed bitmap load into ReadBmpInfo(), ReadBmp() 
> ./unified maxres.bmp
<img width="400"  alt="Screenshot 2026-11-25 at 6 06 45 PM" src="https://github.com/user-attachments/assets/5cacaf96-1736-417f-a4d6-6e0120a128a6" />

## PinnedMem
Clone of RGBInputs project with use of PinnedMem
Changed bitmap load into ReadBmpInfo(), ReadBmp()
> ./pin snail.bmp
<img width="400" alt="Screenshot 2026-11-25 at 6 07 20 PM" src="https://github.com/user-attachments/assets/3e6e1453-b9ef-4d66-b2db-dec0563d0e8c" />

## Parallel BPN by geromidg
Modified project to serve our configuration (RGB)
Improved accuracy with less nodes ?
#define NETWORK_CONFIGURATION {3, 1000, 3}
<img width="574" height="252" alt="Screenshot 2026-11-27 at 6 56 37 PM" src="https://github.com/user-attachments/assets/c9584848-5b4e-4bf0-89ee-464e77d3800d" />

#define NETWORK_CONFIGURATION {3, 600, 3}
<img width="243" height="132" alt="Screenshot 2026-11-27 at 6 49 07 PM" src="https://github.com/user-attachments/assets/b4d72ae1-74e5-42ba-bcd0-12e00a073aed" />


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

6. Parallel training BPN by geromidg, Github
https://github.com/geromidg/backpropagation_cuda

