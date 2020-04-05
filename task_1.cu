#include <stdio.h>
#include "utils/utils.h"

// ~TODO 3~
// Modify the kernel below such as each element of the 
// array will be now equal to 0 if it is an even number
// or 1, if it is an odd number
__global__ void kernel_parity_id(int *a, int N) {
    // Compute the global element index this thread should process
  	unsigned int i = threadIdx.x + blockDim.x * blockIdx.x;

  	// Avoid accessing out of bounds elements
    if (i < N)
    {
    	a[i] = i % 2;
  	}
}

// ~TODO 4~
// Modify the kernel below such as each element will
// be equal to the BLOCK ID this computation takes
// place.
__global__ void kernel_block_id(int *a, int N) {
    // Compute the global element index this thread should process
  	unsigned int i = threadIdx.x + blockDim.x * blockIdx.x;

  	// Avoid accessing out of bounds elements
    if (i < N) 
    {
    	a[i] = blockIdx.x;
  	}
}

// ~TODO 5~
// Modify the kernel below such as each element will
// be equal to the THREAD ID this computation takes
// place.
__global__ void kernel_thread_id(int *a, int N) {
    // Compute the global element index this thread should process
  	unsigned int i = threadIdx.x + blockDim.x * blockIdx.x;

  	// Avoid accessing out of bounds elements
    if (i < N) 
    {
    	a[i] = threadIdx.x;
    }
}

int main(void) {
    int nDevices;

    // Get the number of CUDA-capable GPU(s)
    cudaGetDeviceCount(&nDevices);

    // ~TODO 1~
    // For each device, show some details in the format below, 
    // then set as active device the first one (assuming there
    // is at least CUDA-capable device). Pay attention to the
    // type of the fields in the cudaDeviceProp structure.
    //
    // Device number: <i>
    //      Device name: <name>
    //      Total memory: <mem>
    //      Memory Clock Rate (KHz): <mcr>
    //      Memory Bus Width (bits): <mbw>
    // 
    // Hint: look for cudaGetDeviceProperties and cudaSetDevice in
    // the Cuda Toolkit Documentation. 
    for (int i = 0; i < nDevices; ++i)
    {
        cudaDeviceProp currentDeviceProperties;
        cudaGetDeviceProperties(&currentDeviceProperties, i);

        printf("%s\n", currentDeviceProperties.name);
        printf("%d\n", currentDeviceProperties.totalGlobalMem);
        printf("%d\n", currentDeviceProperties.memoryClockRate);
        printf("%d\n", currentDeviceProperties.memoryBusWidth);
    }

    cudaSetDevice(0);

    // ~TODO 2~
    // With information from example_2.cu, allocate an array with
    // integers (where a[i] = i). Then, modify the three kernels
    // above and execute them using 4 blocks, each with 4 threads.
    // Hint: num_elements = block_size * block_no (see example_2)
    //
    // You can use the fill_array_int(int *a, int n) function (from utils)
    // to fill your array as many times you want.

    int block_size = 4;
    int blocks_no = 4;
    int num_elements = block_size * blocks_no;
  	const int num_bytes = num_elements * sizeof(int);

    int *host_array_a = (int*)malloc(num_bytes);

    int *device_array_a;
    cudaMalloc((void **) &device_array_a, num_bytes);

    // If any memory allocation failed, report an error message
    if (host_array_a == 0 || device_array_a == 0) 
    {
    	printf("[HOST] Couldn't allocate memory\n");
    	return 1;
    }
      
    fill_array_int(host_array_a, num_elements);
    cudaMemcpy(device_array_a, host_array_a, num_bytes, cudaMemcpyHostToDevice);

    // ~TODO 3~
    // Execute kernel_parity_id kernel and then copy from 
    // the device to the host; call cudaDeviceSynchronize()
    // after a kernel execution for safety purposes.
    //
    // Uncomment the line below to check your results

    // Launch the kernel
    kernel_parity_id<<<blocks_no, block_size>>>(device_array_a, num_elements);
    cudaDeviceSynchronize();
  	cudaMemcpy(host_array_a, device_array_a, num_bytes, cudaMemcpyDeviceToHost);
    
    check_task_1(3, host_array_a);

    // ~TODO 4~
    // Execute kernel_block_id kernel and then copy from 
    // the device to the host;
    //
    // Uncomment the line below to check your results

    // Explicatie: Sunt 4 block-uri de dim 4, deci va pune aceeasi valoare de 4 ori, apoi se va schimba
    kernel_block_id<<<blocks_no, block_size>>>(device_array_a, num_elements);
    cudaDeviceSynchronize();
  	cudaMemcpy(host_array_a, device_array_a, num_bytes, cudaMemcpyDeviceToHost);

    check_task_1(4, host_array_a);

    // ~TODO 5~
    // Execute kernel_thread_id kernel and then copy from 
    // the device to the host;
    //
    // Uncomment the line below to check your results
    
    // Explicatie: Sunt 4 thread-uri per block, deci va pune 0 1 2 3 0 1 2 3...
    kernel_thread_id<<<blocks_no, block_size>>>(device_array_a, num_elements);
    cudaDeviceSynchronize();
  	cudaMemcpy(host_array_a, device_array_a, num_bytes, cudaMemcpyDeviceToHost);

    check_task_1(5, host_array_a);

    // TODO 6: Free the memory
    free(host_array_a);
	cudaFree(device_array_a);
    return 0;
}