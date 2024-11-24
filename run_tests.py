import subprocess
import csv

# Configurações para os testes
malhas = [256, 512, 1024]         # Tamanhos da malha (n)
threads_bloco = [8, 16, 32]       # Número de threads por bloco (t)
iteracoes = 100                   # Número fixo de iterações
output_file = "results.csv"       # Arquivo para salvar os resultados

# Função para calcular o número de blocos na grade
def calcular_blocos(n, t):
    return (n + t - 1) // t  # Equivalente ao ceil(n / t)

# Função para executar o programa e capturar a saída
def executar_programa(n, t, b, iteracoes):
    try:
        comando = ["./heat_cuda", str(n), str(iteracoes), str(t), str(b)]
        resultado = subprocess.run(comando, text=True, capture_output=True, check=True)
        return resultado.stdout
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o comando: {e}")
        return None

# Função para extrair tempos de execução da saída
def extrair_tempos(saida):
    tempo_cpu = None
    tempo_gpu = None
    for linha in saida.split("\n"):
        if "Tempo de execução na CPU" in linha:
            tempo_cpu = float(linha.split()[-2])  # Último número antes de 'segundos'
        elif "Tempo de execução na GPU" in linha:
            tempo_gpu = float(linha.split()[-2])  # Último número antes de 'ms'
    return tempo_cpu, tempo_gpu

# Função principal para realizar os testes
def main():
    # Abrir arquivo CSV para salvar os resultados
    with open(output_file, mode="w", newline="") as file:
        writer = csv.writer(file)
        # Cabeçalho do CSV
        writer.writerow(["Malha (n)", "Threads/Bloco (t)", "Blocos/Grade (b)", 
                         "Tempo CPU (s)", "Tempo GPU (ms)", "Speedup"])

        # Realizar os testes para diferentes configurações
        for n in malhas:
            for t in threads_bloco:
                b = calcular_blocos(n, t)
                print(f"Executando: n={n}, t={t}, b={b}")

                # Executar o programa
                saida = executar_programa(n, t, b, iteracoes)
                if saida is None:
                    print(f"Erro ao executar para n={n}, t={t}, b={b}. Pulando...")
                    continue

                # Extrair os tempos da saída
                tempo_cpu, tempo_gpu = extrair_tempos(saida)
                if tempo_cpu is None or tempo_gpu is None:
                    print(f"Falha ao extrair tempos para n={n}, t={t}, b={b}. Pulando...")
                    continue

                # Calcular o speedup
                speedup = tempo_cpu / (tempo_gpu / 1000.0)  # Converter GPU para segundos

                # Salvar os resultados no CSV
                writer.writerow([n, t, b, tempo_cpu, tempo_gpu, round(speedup, 2)])

        print(f"Testes concluídos! Resultados salvos em {output_file}")

if __name__ == "__main__":
    main()

