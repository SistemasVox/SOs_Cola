#!/bin/bash
#$ sed -i 's/\r//' meu_script.sh # linha adicionada para remover caracteres de retorno de carro

MAX_NUM=25 # define o valor máximo de números a serem gerados
N_NUMBERS=15 # define o número de números a serem gerados

numbers=() # cria um array vazio para armazenar os números gerados

# Gera os números aleatórios
for i in $(seq 1 $MAX_NUM); do # gera uma sequência de números de 1 a MAX_NUM e itera sobre eles
    numbers+=("$i") # adiciona cada número à lista de números gerados
done

for i in $(seq 0 $((N_NUMBERS - 1))); do # itera pelo número de números a serem gerados
    randomIndex=$((RANDOM % (MAX_NUM - i) + i)) # gera um índice aleatório dentro do intervalo não processado
    temp=${numbers[i]} # armazena o valor atual do número atual
    numbers[i]=${numbers[randomIndex]} # move o número aleatório selecionado para a posição atual
    numbers[randomIndex]=$temp # insere o valor original do número atual no local anteriormente ocupado pelo número aleatório selecionado
done

# Mostra os números aleatórios
echo -n "Os $N_NUMBERS números aleatórios gerados são: " # exibe a mensagem de cabeçalho
for i in $(seq 0 $((N_NUMBERS - 1))); do # itera pelo número de números a serem exibidos
    echo -n "${numbers[i]} " # exibe cada número, separado por um espaço
done
echo "" # exibe uma quebra de linha

# Ordena os números por inserção
for i in $(seq 0 $((N_NUMBERS - 1))); do # itera pelo número de números a serem ordenados
    current=${numbers[i]} # armazena o valor atual do número
    j=$((i - 1)) # define o índice do número anterior
    while [ $j -ge 0 ] && [ ${numbers[j]} -gt $current ]; do # enquanto o número anterior é maior do que o número atual
        numbers[$((j+1))]=${numbers[j]} # move o número anterior uma posição à frente
        j=$((j-1)) # atualiza o índice do número anterior
    done
    numbers[$((j+1))]=$current # insere o número atual na posição correta na lista ordenada
done

# Mostra os números ordenados
echo -n "Os números gerados e ordenados são: " # exibe a mensagem de cabeçalho
for i in $(seq 0 $((N_NUMBERS - 1))); do # itera pelo número de números a serem exibidos
    printf "%02d " "${numbers[i]}" # exibe cada número, formatado com 2 dígitos e separados por um espaço
done
echo "" # exibe uma quebra de linha

# Mostra os números ausentes
echo -n "Os números AUSENTES são: " # exibe a mensagem de cabeçalho
for i in $(seq $N_NUMBERS $((MAX_NUM - 1))); do # itera pelo número de números ausentes
    printf "%02d " "${numbers[i]}" # exibe cada número ausente, formatado com 2 dígitos
done
echo "" # exibe uma quebra de linha