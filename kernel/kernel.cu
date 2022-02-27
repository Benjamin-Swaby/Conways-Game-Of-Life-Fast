#include "kernel.cuh"
#include "math.h"
#include "io.hpp"

__global__ void step(int *arr, int *result, size_t N, int width) {
    int index =  blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

   for(int i = index; i < N; i += stride)
   {
        int live_neighbours = 0;
        int neighbour_indexes[8];

        neighbour_indexes[0] = (i - width) - 1; // top left
        neighbour_indexes[1] = (i - width); // top
        neighbour_indexes[2] = (i - width) + 1; // top right

        neighbour_indexes[3] = (i - 1); // left
        neighbour_indexes[4] = (i + 1); // right

        neighbour_indexes[5] = (i + width) - 1; // bottom left
        neighbour_indexes[6] = (i + width); // bottom
        neighbour_indexes[7] = (i + width) + 1; // bottom right


        // if the top left isn't at the end of the line or before the array
        if (!(neighbour_indexes[0] < 0 || neighbour_indexes[0] % width == (width - 1))) {
            if (arr[neighbour_indexes[0]]) {
                live_neighbours++;
            }
        }

        // if the top one does exist 
        if (!(neighbour_indexes[1] < 0)) {
            if (arr[neighbour_indexes[1]]) {
                live_neighbours++;
            }
        }

        // if the top right isn't at the start of a line or before the array
        if (!(neighbour_indexes[2] < 0 || neighbour_indexes[2] % width == 0)) {
            if (arr[neighbour_indexes[2]]) {
                live_neighbours++;
            }
        }

        // if the left isn't at the end of a line
        if (!(neighbour_indexes[3] % width == (width - 1)) || neighbour_indexes[3] < 0) {
            if (arr[neighbour_indexes[3]]) {
                live_neighbours++;
            }
        }

        // if the right isn't at the start of the next line
        if (!(neighbour_indexes[4] % width == 0) || neighbour_indexes[4] > N) {
            if (arr[neighbour_indexes[4]]) {
                live_neighbours++;
            }
        }

        // if the bottom left isn't at the end of a line
        if (!(neighbour_indexes[5] > N || neighbour_indexes[5] % width == (width - 1))) {
            if (arr[neighbour_indexes[5]]) {
                live_neighbours++;
            }
        }

        // if the bottom one isn't out of the array
        if (neighbour_indexes[6] < N) {
            if (arr[neighbour_indexes[6]]) {
                live_neighbours++;
            }
        }

        // if the bottom right isn't at the start of a line or out of the array
        if (!(neighbour_indexes[7] > N || neighbour_indexes[7] % width == 0)) {
            if (arr[neighbour_indexes[7]]) {
                live_neighbours++;
            }
        }

        // -----------------------------------------
        

        //printf("Cell %d has %d ln \n" , i , live_neighbours);

        if (arr[i] && (live_neighbours == 2 || live_neighbours == 3)) {
            result[i] = 1;
        }else if (!arr[i] && (live_neighbours == 3))
        {
            result[i] = 1;
        }else {
            if(arr[i]) {
                result[i] = 0;
            }else if (!arr[i]) {
                result[i] = 0;
            }
        }
        

   }
}



cudaDeviceProp getDetails(int deviceId)
{
    cudaDeviceProp props;
    cudaGetDeviceProperties(&props, deviceId);
    return props;
}



inline __global__ void copy(int *result, int *input, int N) {
    int index =  blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for(int i = index; i < N; i += stride) {
        input[i] = result[i]; 
    }
}

#define multi 20
void cgol::conways_game_of_life(int *input, int N, int generations, bool save) {

    printf("Initialising GPU...\n");
    int deviceId;
    cudaGetDevice(&deviceId);
    cudaDeviceProp props = getDetails(deviceId);


    size_t size = sizeof(int) * N;

    int *result;
    int *d_result;
    int *d_input;

    result = (int*)malloc(size);

    cudaMalloc((void **)&d_input, size);
    cudaMalloc((void**)&d_result, size);
    cudaMemcpy(d_input, input, size, cudaMemcpyHostToDevice);
    
    int threads_per_block = 512;
    printf("Number of SMs : %d\n\r", props.multiProcessorCount);
    int number_of_blocks = props.multiProcessorCount * multi;

    cudaError_t step_error;
    cudaError_t async_error;

    int width = (int)sqrt(N); // Because it's a square this should always be true.

    if (width * width != N) {
        // check to make sure it is
        printf("Err: width is not correct. \n %d * %d != %d", width, width, N);
        exit(-2);
    }

    printf("Executing:\n");

    for (int i = 0; i < generations; i++) {
        step<<<threads_per_block, number_of_blocks>>>(d_input, d_result, N, width);
        
        // check for errors
        step_error = cudaGetLastError();
        if(step_error != cudaSuccess) printf("Error: %s\n", cudaGetErrorString(step_error));

        async_error = cudaDeviceSynchronize();
        if(async_error != cudaSuccess) printf("Error: %s\n", cudaGetErrorString(async_error));

        // result now contains the result of cgol.
        // we want to write that to a file and then copy that to d_input and run again.
        if(save) {
            cudaMemcpy(result, d_result, size, cudaMemcpyDeviceToHost);
            cgol::write("./out/map" + std::to_string(i) + ".mp", result, N);
        }
        
        // copy result as d_input ready for the next kernel call
        copy<<<threads_per_block,number_of_blocks>>>(d_result, d_input, N);
    }

}