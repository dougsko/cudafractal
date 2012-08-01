#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <gd.h>

#define DIM 1000

int
makePNG(char *imgData)
{
    gdImagePtr image;
    FILE *out;
    int color;

    image = gdImageCreate(DIM, DIM);
    color = gdImageColorAllocate(image, 0, 0, 0); // R, G, B
    gdImageSetPixel(image, 0, 0, color);
    out = fopen("foo.png", "wb");
    gdImagePng(image, out);
    fclose(out);
    gdImageDestroy(image);

    return 0;
}

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
    const float scale = 1.5;
    float jx = scale * (float)(DIM/2 - x)/(DIM/2);
    float jy = scale * (float)(DIM/2 - y)/(DIM/2);

    cuComplex c(-0.8, 0.156);
    cuComplex a(jx, jy);

    int i = 0;
    for(i = 0; i < 200; i++)
    {
        a = a * a + c;
        if(a.magnatude2() > 1000)
            return 0;
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
    ptr[offset*4 + 0] = 255 * juliaValue;
    ptr[offset*4 + 1] = 0;
    ptr[offset*4 + 2] = 0;
    ptr[offset*4 + 3] = 255;
}

int
main(void)
{
    unsigned char *dev_bitmap;
    unsigned char bitmap[4000];

    int i;
    for( i = 0; i <= DIM*4; i++)
    {
        bitmap[i] = 0;
    }

    cudaMalloc((void **) &dev_bitmap, DIM * DIM);

    cudaMemcpy(dev_bitmap, bitmap, DIM * 4 * sizeof(int), cudaMemcpyHostToDevice);

    dim3 grid(DIM, DIM);
    kernel<<<grid, 1>>>(dev_bitmap);

    cudaMemcpy(bitmap, dev_bitmap, DIM * 4 * sizeof(int), cudaMemcpyDeviceToHost);
    for(i = 0; i <= 4000; i++)
    {
        printf("%d\n", bitmap[i]);
    }

    cudaFree(dev_bitmap);

    return 0;
}

