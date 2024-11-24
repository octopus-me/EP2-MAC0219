  GNU nano 7.2                                                                                                                                                                                                                                                                                                   heat.cu                                                                                                                                                                                                                                                                                                            
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <time.h>
#include <math.h>

#define WALL_TEMP 20.0
#define FIREPLACE_TEMP 100.0

#define FIREPLACE_START 3
#define FIREPLACE_END 7
#define ROOM_SIZE 10

// Kernel CUDA para calcular Jacobi na GPU
__global__ void jacobi_kernel(double *d_h, double *d_g, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i > 0 && i < n - 1 && j > 0 && j < n - 1) {
        d_g[i * n + j] = 0.25 * (d_h[(i - 1) * n + j] + d_h[(i + 1) * n + j] +
                                 d_h[i * n + (j - 1)] + d_h[i * n + (j + 1)]);
    } else if (i == 0 || i == n - 1 || j == 0 || j == n - 1) {
        d_g[i * n + j] = d_h[i * n + j]; // Copiar diretamente os valores das bordas
    }
}

// Função para inicializar a matriz com condições de contorno
void initialize(double *h, int n) {
    int fireplace_start = (FIREPLACE_START * n) / ROOM_SIZE;
    int fireplace_end = (FIREPLACE_END * n) / ROOM_SIZE;

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i == 0 || i == n - 1 || j == 0 || j == n - 1) {
                h[i * n + j] = (i == n - 1 && j >= fireplace_start && j <= fireplace_end) ? FIREPLACE_TEMP : WALL_TEMP;
            } else {
                h[i * n + j] = 0.0;
            }
        }
    }
}

// Função Jacobi sequencial para execução na CPU
void jacobi_iteration_cpu(double *h, double *g, int n, int iter_limit) {
    for (int iter = 0; iter < iter_limit; iter++) {
        for (int i = 1; i < n - 1; i++) {
            for (int j = 1; j < n - 1; j++) {
                g[i * n + j] = 0.25 * (h[(i - 1) * n + j] + h[(i + 1) * n + j] +
                                       h[i * n + (j - 1)] + h[i * n + (j + 1)]);
            }
        }
        for (int i = 1; i < n - 1; i++) {
            for (int j = 1; j < n - 1; j++) {
                h[i * n + j] = g[i * n + j];
            }
        }
    }
}

// Função para calcular o tempo de execução na CPU
double calculate_elapsed_time(struct timespec start, struct timespec end) {
    double start_sec = (double)start.tv_sec * 1e9 + (double)start.tv_nsec;
    double end_sec = (double)end.tv_sec * 1e9 + (double)end.tv_nsec;
    return (end_sec - start_sec) / 1e9;
}

// Função para validar os resultados de CPU e GPU
void validate(double *h_cpu, double *h_gpu, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (fabs(h_cpu[i * n + j] - h_gpu[i * n + j]) > 1e-6) {
                printf("Discrepância encontrada em (%d, %d): CPU=%.6f, GPU=%.6f\n", i, j, h_cpu[i * n + j], h_gpu[i * n + j]);
                return;
            }
        }
    }
    printf("Validação bem-sucedida: CPU e GPU produzem os mesmos resultados.\n");
}

// Função principal
int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Uso: %s <n> <iter_limit> <threads_por_bloco> <blocos_por_grade>\n", argv[0]);
        return 1;
    }

    int n = atoi(argv[1]);
    int iter_limit = atoi(argv[2]);
    int threads_per_block = atoi(argv[3]);
    int blocks_per_grid = atoi(argv[4]);

    size_t size = n * n * sizeof(double);
    double *h_h = (double *)malloc(size);
    double *h_g = (double *)malloc(size);
    double *h_h_cpu = (double *)malloc(size);
    double *g_h_cpu = (double *)malloc(size);

    double *d_h, *d_g;
    cudaMalloc(&d_h, size);
    cudaMalloc(&d_g, size);

    initialize(h_h, n);
    memcpy(h_h_cpu, h_h, size); // Copiar os valores iniciais para a CPU

    cudaMemcpy(d_h, h_h, size, cudaMemcpyHostToDevice);

    dim3 threads(threads_per_block, threads_per_block);
    dim3 blocks(blocks_per_grid, blocks_per_grid);

    // Executar Jacobi na CPU
    struct timespec start_cpu, end_cpu;
    clock_gettime(CLOCK_MONOTONIC, &start_cpu);
    jacobi_iteration_cpu(h_h_cpu, g_h_cpu, n, iter_limit);
    clock_gettime(CLOCK_MONOTONIC, &end_cpu);

    double elapsed_time_cpu = calculate_elapsed_time(start_cpu, end_cpu);
    printf("Tempo de execução na CPU: %.9f segundos\n", elapsed_time_cpu);

    // Executar Jacobi na GPU
    cudaEvent_t start_gpu, stop_gpu;
    cudaEventCreate(&start_gpu);
    cudaEventCreate(&stop_gpu);

    cudaEventRecord(start_gpu);
    for (int iter = 0; iter < iter_limit; iter++) {
        jacobi_kernel<<<blocks, threads>>>(d_h, d_g, n);
        cudaMemcpy(d_h, d_g, size, cudaMemcpyDeviceToDevice);
    }
    cudaEventRecord(stop_gpu);

    cudaMemcpy(h_g, d_h, size, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop_gpu);

    float elapsed_time_gpu;
    cudaEventElapsedTime(&elapsed_time_gpu, start_gpu, stop_gpu);
    printf("Tempo de execução na GPU: %.3f ms\n", elapsed_time_gpu);

    // Comparar os resultados
    validate(h_h_cpu, h_g, n);

    // Limpeza
    free(h_h);
    free(h_g);
    free(h_h_cpu);
    free(g_h_cpu);
    cudaFree(d_h);
    cudaFree(d_g);

    return 0;
}