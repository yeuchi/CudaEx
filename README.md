# EE5351 Team Project Color Mapping

## CUDA Starter
Learning CUDA parallel programming.  To start, enable nvcc compiler driver as Stephen Smith suggests in his article[1].

> nvcc version 10.2

<img width="400" alt="Screenshot 2026-09-13 at 4 57 44 PM" src="https://github.com/user-attachments/assets/bbf94010-fd45-40d6-91f1-b06fd10fe410" />

## BPN 
Original Back propagation neural network (1 hidden layer) for color mapping from 1996.
It was written to run on a CPU. 
Training generally took 4+ hours.

## RGB test image generation
Generates a raw binary image from (0,0,0) -> (255,255,255)
This is a full color gamut RGB input for a look up table.

> ./rgb 
<img width="1000" alt="Screenshot 2026-11-08 at 9 28 34 AM" src="https://github.com/user-attachments/assets/3a7e80d7-f35a-45db-954b-0f2521041e7e" />

# Reference
1. Stephen Smith's Blog, Playing with CUDA on My NVIDIA Jetson Nano, June 20, 2020
https://smist08.wordpress.com/2019/04/03/playing-with-cuda-on-my-nvidia-jetson-nano/

2. NNC Color Mapping \
https://library.imaging.org/cic/articles/1/1/art00010

3. Variable Rectilinear interpolation \
https://www.imaging.org/common/uploaded%20files/pdfs/Papers/1998/RP-0-69/2210.pdf

