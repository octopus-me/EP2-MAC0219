# Compilador e flags para a versão sequencial
CC = gcc
CFLAGS = -Wall -Wextra -O2

# Compilador e flags para a versão CUDA
NVCC = /usr/local/cuda/bin/nvcc
CUDAPATH = /usr/local/cuda
NVCCFLAGS = -I$(CUDAPATH)/include
LFLAGS = -L$(CUDAPATH)/lib64 -lcuda -lcudart -lm

# Alvos
all: heat_seq heat_cuda

# Compilação da versão sequencial
heat_seq: heat_seq.o
	$(CC) $(CFLAGS) -o heat_seq heat_seq.o

heat_seq.o: heat.c
	$(CC) $(CFLAGS) -c heat.c

# Compilação da versão CUDA
heat_cuda: heat.cu
	$(NVCC) $(NVCCFLAGS) $(LFLAGS) -o heat_cuda heat.cu

# Limpeza dos arquivos objeto e executáveis
clean:
	rm -f heat_seq heat_seq.o heat_cuda
