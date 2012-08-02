#include <gd.h>

int
makePNG(char *imgData, int DIM)
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
