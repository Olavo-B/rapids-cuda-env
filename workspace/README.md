# ⚡ CUDA Jupyter Workspace Guide

Este diretório é o seu workspace local persistente. Qualquer notebook, código-fonte (`.cu`, `.cpp`) ou dataset salvo aqui permanecerá na sua máquina host de forma segura, mesmo se o container Docker for reiniciado ou destruído.

O ambiente já vem configurado com **nvcc4jupyter**, uma extensão que permite escrever, compilar, executar e realizar o profiling de código CUDA C++ diretamente nas células do Jupyter.

## 🔌 1. Carregando a Extensão

Antes de rodar qualquer código CUDA em um novo notebook, carregue a extensão executando este comando na primeira célula:

\`\`\`python
%load_ext nvcc4jupyter
\`\`\`

## ⚙️ 2. Configurando Flags Globais (Importante)

Para evitar erros de compatibilidade e garantir o máximo desempenho, você deve instruir o compilador a usar a arquitetura de hardware correta (`sm_89` para a RTX 4060) e aplicar otimizações de nível máximo (`-O3`). 

Em vez de repetir essas flags em cada célula, você pode defini-las globalmente. Na célula seguinte, execute o comando Python:

\`\`\`python
import nvcc4jupyter
nvcc4jupyter.set_defaults(compiler_args="-gencode arch=compute_89,code=sm_89 -O3")
\`\`\`

> [!TIP]
> Com este comando ativo no notebook, qualquer célula mágica `%%cuda` que você rodar herdará essas flags automaticamente durante a compilação.

## 🚀 3. Uso Básico

Agora você pode escrever e executar código CUDA nativo. A célula será automaticamente salva como um arquivo temporário, compilada e executada.

\`\`\`cpp
%%cuda
#include <iostream>

__global__ void helloKernel() {
    printf("Executando thread %d no bloco %d\n", threadIdx.x, blockIdx.x);
}

int main() {
    helloKernel<<<2, 4>>>();
    cudaDeviceSynchronize();
    return 0;
}
\`\`\`

## ⏱️ 4. Profiling de Performance com Nsight Compute

Você pode utilizar as ferramentas de profiling da NVIDIA diretamente no notebook para analisar gargalos de hardware em seus kernels.

Para executar o Nsight Compute (`ncu`) na célula, utilize a flag `--profile` acompanhada dos argumentos do profiler. O exemplo abaixo analisa a seção de "Speed Of Light" (que mede a eficiência da memória e da computação em relação aos limites teóricos da GPU):

\`\`\`cpp
%%cuda --profile --profiler-args "--section SpeedOfLight"
#include <iostream>

// Seu código CUDA complexo para ser analisado irá aqui
int main() {
    std::cout << "O profiler irá interceptar e analisar esta execução." << std::endl;
    return 0;
}
\`\`\`

> [!WARNING]
> Para o profiling funcionar, o seu container Docker deve ter sido iniciado com a flag `--cap-add=SYS_ADMIN`.
