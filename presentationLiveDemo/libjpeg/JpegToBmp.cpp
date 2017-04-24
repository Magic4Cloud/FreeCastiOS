//
//  JpegToBmp.cpp
//  presentationLiveDemo
//
//  Created by rakwireless on 2017/2/16.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#include "JpegToBmp.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include "jpeglib.h"

#pragma pack(1)
typedef struct __BITMAPFILEHEADER__
{
    u_int16_t bfType;
    u_int32_t bfSize;
    u_int16_t bfReserved1;
    u_int16_t bfReserved2;
    u_int32_t bfOffBits;
}BITMAPFILEHEADER;

typedef struct __BITMAPINFOHEADER
{
    u_int32_t biSize;
    u_int32_t biWidth;
    u_int32_t biHeight;
    u_int16_t biPlanes;
    u_int16_t biBitCount;
    u_int32_t biCompression;
    u_int32_t biSizeImage;
    u_int32_t biXPelsPerMeter;
    u_int32_t biYPelsPerMeter;
    u_int32_t biClrUsed;
    u_int32_t biClrImportant;
}BITMAPINFOHEADER;

#define BYTE_PER_PIX 3
int create_bmp_header(BITMAPFILEHEADER* bmphead, BITMAPINFOHEADER* infohead, int w, int h)
{
    bmphead->bfType = 0x4D42; //must be 0x4D42='BM'
    bmphead->bfSize= w*h*BYTE_PER_PIX+14+40;
    bmphead->bfReserved1= 0x00;
    bmphead->bfReserved2= 0x00;
    bmphead->bfOffBits = 14+40;
    
    infohead->biSize = sizeof(BITMAPINFOHEADER);
    infohead->biWidth = w;
    infohead->biHeight = -h;
    infohead->biPlanes = 1;
    infohead->biBitCount = BYTE_PER_PIX*8;
    infohead->biCompression= 0;
    infohead->biSizeImage= w*h*BYTE_PER_PIX;//640 * 480 * 3;
    infohead->biXPelsPerMeter= 0x0;
    infohead->biYPelsPerMeter= 0x0;
    infohead->biClrUsed = 0;
    infohead->biClrImportant = 0;
    return 0;
}



struct my_error_mgr {
    struct jpeg_error_mgr pub;    /* "public" fields */
    
    jmp_buf setjmp_buffer;    /* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

/*
 * Here's the routine that will replace the standard error_exit method:
 */

METHODDEF(void)
my_error_exit (j_common_ptr cinfo)
{
    /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
    my_error_ptr myerr = (my_error_ptr) cinfo->err;
    
    /* Always display the message. */
    /* We could postpone this until after returning, if we chose. */
    (*cinfo->err->output_message) (cinfo);
    
    /* Return control to the setjmp point */
    longjmp(myerr->setjmp_buffer, 1);
}


/*
 * Sample routine for JPEG decompression. We assume that the source file name
 * is passed in. We want to return 1 on success, 0 on error.
 */

int read_JPEG_file (char* bmpfile, char * jpgfile)
{
    BITMAPFILEHEADER bmphead;
    BITMAPINFOHEADER infohead;
    FILE * bmp_fp = NULL;
    /* This struct contains the JPEG decompression parameters and pointers to
     * working space (which is allocated as needed by the JPEG library).
     */
    struct jpeg_decompress_struct cinfo;
    /* We use our private extension JPEG error handler.
     * Note that this struct must live as long as the main JPEG parameter
     * struct, to avoid dangling-pointer problems.
     */
    struct my_error_mgr jerr;
    /* More stuff */
    FILE * jpg_file;        /* source file */
    JSAMPARRAY buffer;        /* Output row buffer */
    int row_stride;        /* physical row width in output buffer */
    
    /* In this example we want to open the input file before doing anything else,
     * so that the setjmp() error recovery below can assume the file is open.
     * VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
     * requires it in order to read binary files.
     */
    
    if ((jpg_file= fopen(jpgfile, "rb")) == NULL) {
        fprintf(stderr, "can't open jpgfile=%s\n", jpgfile);
        return 0;
    }
    
    //prepare for bmp write
    if (NULL == (bmp_fp = fopen(bmpfile,"wb")))
    {
        fprintf(stderr, "can't open bmpfile=%s\n", bmpfile);
        return -1;
    }
    
    /* Step 1: allocate and initialize JPEG decompression object */
    
    /* We set up the normal JPEG error routines, then override error_exit. */
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = my_error_exit;
    /* Establish the setjmp return context for my_error_exit to use. */
    if (setjmp(jerr.setjmp_buffer)) {
        /* If we get here, the JPEG code has signaled an error.
         * We need to clean up the JPEG object, close the input file, and return.
         */
        jpeg_destroy_decompress(&cinfo);
        fclose(jpg_file);
        return 0;
    }
    /* Now we can initialize the JPEG decompression object. */
    jpeg_create_decompress(&cinfo);
    
    /* Step 2: specify data source (eg, a file) */
    
    jpeg_stdio_src(&cinfo, jpg_file);
    
    /* Step 3: read file parameters with jpeg_read_header() */
    
    (void) jpeg_read_header(&cinfo, TRUE);
    printf("w=%d,h=%d\n", cinfo.image_width, cinfo.image_height);
    
    create_bmp_header(&bmphead, &infohead, cinfo.image_width, cinfo.image_height);
    fwrite(&bmphead, 14, 1, bmp_fp);
    fwrite(&infohead, 40, 1, bmp_fp);
    /* We can ignore the return value from jpeg_read_header since
     * (a) suspension is not possible with the stdio data source, and
     * (b) we passed TRUE to reject a tables-only JPEG file as an error.
     * See libjpeg.doc for more info.
     */
    
    /* Step 4: set parameters for decompression */
    
    /* In this example, we don't need to change any of the defaults set by
     * jpeg_read_header(), so we do nothing here.
     */
    
    /* Step 5: Start decompressor */
    
    (void) jpeg_start_decompress(&cinfo);
    /* We can ignore the return value since suspension is not possible
     * with the stdio data source.
     */
    
    /* We may need to do some setup of our own at this point before reading
     * the data. After jpeg_start_decompress() we have the correct scaled
     * output image dimensions available, as well as the output colormap
     * if we asked for color quantization.
     * In this example, we need to make an output work buffer of the right size.
     */
    /* JSAMPLEs per row in output buffer */
    row_stride = cinfo.output_width * cinfo.output_components;
    /* Make a one-row-high sample array that will go away when done with image */
    buffer = (*cinfo.mem->alloc_sarray)
    ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
    
    /* Step 6: while (scan lines remain to be read) */
    /* jpeg_read_scanlines(...); */
    
    /* Here we use the library's state variable cinfo.output_scanline as the
     * loop counter, so that we don't have to keep track ourselves.
     */
    while (cinfo.output_scanline < cinfo.output_height) {
        /* jpeg_read_scanlines expects an array of pointers to scanlines.
         * Here the array is only one element long, but you could ask for
         * more than one scanline at a time if that's more convenient.
         */
        (void) jpeg_read_scanlines(&cinfo, buffer, 1);
        /* Assume put_scanline_someplace wants a pointer and sample count. */
        //put_scanline_someplace(buffer[0], row_stride);
        fwrite(buffer[0],row_stride,1, bmp_fp);
    }
    fclose(bmp_fp);
    
    /* Step 7: Finish decompression */
    
    (void) jpeg_finish_decompress(&cinfo);
    /* We can ignore the return value since suspension is not possible
     * with the stdio data source.
     */
    
    /* Step 8: Release JPEG decompression object */
    
    /* This is an important step since it will release a good deal of memory. */
    jpeg_destroy_decompress(&cinfo);
    
    /* After finish_decompress, we can close the input file.
     * Here we postpone it until after no more JPEG errors are possible,
     * so as to simplify the setjmp error logic above. (Actually, I don't
     * think that jpeg_destroy can do an error exit, but why assume anything...)
     */
    fclose(jpg_file);
    
    /* At this point you may want to check to see whether any corrupt-data
     * warnings occurred (test whether jerr.pub.num_warnings is nonzero).
     */
    
    /* And we're */
    return 1;
}


int main ( int argc, char *argv[] )
{
    //char filename[] = "./testimg.jpg";
    char jpgfile[] = "./640_480.jpg";
    char bmpfile[] = "./640_480.bmp";
    read_JPEG_file(bmpfile, jpgfile);
    printf("read over\n");
    return EXIT_SUCCESS;
}
