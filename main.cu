#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

// Define constants and data types

//1MB in global memory
#define STORAGE_SIZE        1085440

// file's maximum size 
#define MAX_FILE_SIZE       1048576

// Data File I/O
#define OUTPUTFILE          "./snapshot.bin"
#define DATAFILE            "./data.bin"


typedef unsigned char uchar;
typedef uint32_t u32;

// G_WRITE mode is 1
const int G_WRITE   = 1;
// G_READ mode is 2
const int G_READ    = 2;

// list all file by size order
const int LS_S      = 3;
// list all file by modified time order
const int LS_D      = 4;
const int RM        = 5;
const int RM_RF     = 6;

// Declare variables
__device__ __managed__ uchar *volume;

// Initialize Function
// ******************************************************************
void init_volume() {
    memset(volume, 0, STORAGE_SIZE*sizeof(uchar));
}

// ******************************************************************

// ******************************************************************
// File I/O Function

// File output use stdio.h Function fopen,fwrite,fclose
void writeBinaryFile(char *fileName, uchar *input, int fileSize) {
    FILE *fptr = fopen(fileName, "wb");
    // Read data from input file
    fwrite(input, sizeof(unsigned char), fileSize, fptr);
	fclose(fptr);
}

// File input use stdio.h Function fopen,fseek,ftell,rewind,fread,fclose
int loadBinaryFile(char *fileName, uchar *input, int fileSize) {
    FILE *fptr = fopen(fileName, "rb");
    // Get size
    fseek(fptr, 0, SEEK_END);
    int size = ftell(fptr);
    rewind(fptr);
    // Read data from input file
    fread(input, sizeof(unsigned char), size, fptr);
    if (fileSize < size) {
        printf("ERROR: Input size is illegal!\n");
    }
	fclose(fptr);
    return size;
}

// ******************************************************************

// ******************************************************************
// File System Operation
__device__ u32 open(char *name, int type) {
    u32 fp = 0;
    printf("Open %s %d\n", name, type);
    return fp;
}

__device__ void write(uchar *src, int len, u32 fp) {
    // Not implement
    printf("Write %s %d %d\n", src, len, fp);
}

__device__ void read(uchar *dst, int len, u32 fp) {
    // Not implement
    printf("Read %s %d %d\n", dst, len, fp);
}


// ******************************************************************

// ******************************************************************
// Kernel function
__global__ void mykernel(uchar *input, uchar *output) {
    //####kernel start####
    u32 fp = open("t.txt\0", G_WRITE);
    write(input, 64, fp);
    fp = open("b.txt\0", G_WRITE);
    write(input+32, 32, fp);
    fp = open("t.txt\0", G_WRITE);
    write(input+32, 32, fp);
    read(output, 32, fp);
    fp = open("b.txt\0", G_WRITE);
    write(input+64, 12, fp);
	gsys(LS_S);
    gsys(LS_D);
    gsys(RM, "t.txt\0");
    gsys(LS_S);
	
	//Bonus Test
	/*fp = open("a.txt\0",G_WRITE);
	write(input+128, 64, fp);
	fp = open("b.txt\0",G_WRITE);
	write(input+256, 32, fp);
	gsys(MKDIR, "soft\0");
	gsys(LS_S);
    gsys(LS_D);
	gsys(CD, "soft\0");
	gsys(PWD);
	*/
    //####kernel end####
}
// ******************************************************************

int main() {
    cudaMallocManaged(&volume, STORAGE_SIZE);
    init_volume();

    uchar *input, *output;
    cudaMallocManaged(&input, MAX_FILE_SIZE);
    cudaMallocManaged(&output, MAX_FILE_SIZE);
    for (int i = 0; i < MAX_FILE_SIZE; i++) {
        output[i] = 0;
    }
    loadBinaryFile(DATAFILE, input, MAX_FILE_SIZE);

    cudaSetDevice(4);
    mykernel<<<1, 1>>>(input, output);
    cudaDeviceSynchronize();
    writeBinaryFile(OUTPUTFILE, output, MAX_FILE_SIZE);
    cudaDeviceReset();

    return 0;
}
