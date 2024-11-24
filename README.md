# Simulação de Distribuição de Calor com CUDA

Este projeto implementa uma simulação bidimensional da distribuição de calor em uma placa, utilizando o método de Jacobi para resolver a equação de condução de calor. A implementação é realizada tanto de forma sequencial na CPU quanto de forma paralela na GPU, empregando CUDA para acelerar o processamento.

## Descrição do Projeto

A simulação modela a distribuição de temperatura em uma placa quadrada, considerando condições de contorno específicas:

-   **Temperatura das paredes:** 20°C
-   **Temperatura da lareira (borda inferior central):** 100°C

O objetivo é calcular a distribuição de temperatura ao longo da placa até que o sistema atinja um estado estacionário.

## Estrutura do Repositório

-   `heat_seq.c`: Implementação sequencial da simulação na CPU.
-   `heat_cuda.cu`: Implementação paralela da simulação na GPU utilizando CUDA.
-   `Makefile`: Script para compilar ambas as versões do programa.
-   `README.md`: Este documento.

## Compilação e Execução

### Pré-requisitos

-   **Compilador GCC:** Para compilar a versão sequencial.
-   **NVIDIA CUDA Toolkit:** Para compilar e executar a versão CUDA.

### Compilação

1.  **Clone o repositório:**
    
    bash
    
    Copiar código
    
    `git clone <URL_DO_REPOSITORIO>
    cd <NOME_DO_DIRETORIO>` 
    
2.  **Compile as versões sequencial e CUDA:**
    
    bash
    
    Copiar código
    
    `make` 
    
    Isso gerará os executáveis `heat_seq` e `heat_cuda`.
    

### Execução

**Versão Sequencial:**

bash

Copiar código

`./heat_seq <tamanho_da_malha> <numero_de_iteracoes>` 

**Versão CUDA:**

bash

Copiar código

`./heat_cuda <tamanho_da_malha> <numero_de_iteracoes> <threads_por_bloco> <blocos_por_grade>` 

**Parâmetros:**

-   `<tamanho_da_malha>` (`n`): Dimensão da malha (por exemplo, 256 para uma malha 256x256).
-   `<numero_de_iteracoes>` (`iter_limit`): Número de iterações do método de Jacobi.
-   `<threads_por_bloco>` (`t`): Número de threads por bloco (apenas para a versão CUDA).
-   `<blocos_por_grade>` (`b`): Número de blocos por grade (apenas para a versão CUDA).

**Exemplo de execução:**

bash

Copiar código

`./heat_seq 256 100
./heat_cuda 256 100 16 16` 

## Resultados e Desempenho

A simulação mede o tempo de execução tanto na CPU quanto na GPU e valida se os resultados são consistentes entre as duas implementações. Os tempos de execução são exibidos no terminal após a conclusão da simulação.

## Observações

-   Certifique-se de que sua GPU suporta CUDA e que os drivers e o CUDA Toolkit estão corretamente instalados.
-   Para diferentes tamanhos de malha e configurações de threads/blocos, o desempenho pode variar. Recomenda-se experimentar diferentes combinações para otimizar o tempo de execução.

## Licença

Este projeto é distribuído sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.

## Autores

-   [Guilherme Wallace](https://github.com/octopus-me)
-   [Mikhail Futorny](https://github.com/MikeFutorny)

Sinta-se à vontade para contribuir com melhorias ou relatar problemas através das issues no GitHub.