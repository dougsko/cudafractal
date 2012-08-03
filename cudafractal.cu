#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include "cpu_bitmap.h"
#include "book.h"
#include "png_helper.h"

#define DIM 1080
#define DIM_X 1920
#define DIM_Y 1080


struct 
cuComplex
{
    float r;
    float i;
    __device__ cuComplex(float a, float b) : r(a), i(b) {}
    
    __device__ float 
    magnatude2(void)
    {
        return r * r + i * i;
    }

    __device__ cuComplex 
    operator*(const cuComplex& a)
    {
        return cuComplex(r*a.r - i*a.i, i*a.r + r*a.i);
    }

    __device__ cuComplex 
    operator+(const cuComplex& a)
    {
        return cuComplex(r+a.r, i+a.i);
    }
};

__device__ int 
julia(int x, int y)
{
    const float scale = 0.8;
    float jx = scale * (float)(DIM_X/2 - x)/(DIM_X/2);
    float jy = scale * (float)(DIM_Y/2 - y)/(DIM_Y/2);
    float mag;

    cuComplex c(-0.8, 0.156);
    cuComplex a(jx, jy);

    int i = 0;
    for(i = 0; i < 200; i++)
    {
        a = a * a + c;
        mag = a.magnatude2();
        if(mag > 1000)
            return mag;
    }
    return 1;
}

__global__ void 
kernel(unsigned char *ptr)
{
    int x = blockIdx.x;
    int y = blockIdx.y;
    int offset = x + y * gridDim.x;

    int juliaValue = julia(x, y);
    if(juliaValue == 1)
        ptr[offset*4 + 0] = 255 * juliaValue;
    else
        ptr[offset*4 + 0] = 0;
    ptr[offset*4 + 1] = 0;
    ptr[offset*4 + 2] = 0;
    ptr[offset*4 + 3] = 255;
}

int
main(void)
{
    unsigned char *dev_bitmap;
    CPUBitmap bitmap(DIM_X, DIM_Y);


    cudaMalloc((void **) &dev_bitmap, bitmap.image_size());

    dim3 grid(DIM_X, DIM_Y);
    kernel<<<grid, 1>>>(dev_bitmap);

    cudaMemcpy(bitmap.get_ptr(), dev_bitmap, bitmap.image_size(), cudaMemcpyDeviceToHost);

    bitmap.display_and_exit();

    cudaFree(dev_bitmap);

    return 0;
}

