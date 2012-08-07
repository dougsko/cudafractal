#include <gd.h>

int
makePNG(unsigned char *imgData, int DIM_X, int DIM_Y)
{
    gdImagePtr image;
    FILE *out;
    int color;

    int k = 0;
    image = gdImageCreate(DIM_X, DIM_Y);
    for(int i = 0; i <= 1920; i++)
    {
        for(int j = 0; j <= 1080; j++)
        {
            //printf("%d\n", imgData[k]);
            color = gdImageColorAllocate(image, imgData[k], 0, 0); // R, G, B
            /*
            if(imgData[k] == 255)
                printf("%d, %d red\n", i, j);
            else
                printf("%d, %d black\n", i, j);

                */
            gdImageSetPixel(image, i, j, color);
            k += 4;
        }
        if(k >= (1920*1080) - 1)
            k = 0;
    }
    out = fopen("foo.png", "wb");
    gdImagePng(image, out);
    fclose(out);
    gdImageDestroy(image);

    return 0;
}
