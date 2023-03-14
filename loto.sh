#!/bin/bash
#$ sed -i 's/\r//' meu_script.sh
MAX_NUM=25
N_NUMBERS=15

numbers=()

# Gera os números aleatórios
for i in $(seq 1 $MAX_NUM); do
    numbers+=("$i")
done

for i in $(seq 0 $((N_NUMBERS - 1))); do
    randomIndex=$((RANDOM % (MAX_NUM - i) + i))
    temp=${numbers[i]}
    numbers[i]=${numbers[randomIndex]}
    numbers[randomIndex]=$temp
done

# Mostra os números aleatórios
echo -n "Os $N_NUMBERS números aleatórios gerados são: "
for i in $(seq 0 $((N_NUMBERS - 1))); do
    echo -n "${numbers[i]} "
done
echo ""

# Ordena os números por inserção
for i in $(seq 0 $((N_NUMBERS - 1))); do
    current=${numbers[i]}
    j=$((i - 1))
    while [ $j -ge 0 ] && [ ${numbers[j]} -gt $current ]; do
        numbers[$((j+1))]=${numbers[j]}
        j=$((j-1))
    done
    numbers[$((j+1))]=$current
done

# Mostra os números ordenados
echo -n "Os números gerados e ordenados são: "
for i in $(seq 0 $((N_NUMBERS - 1))); do
    printf "%02d " "${numbers[i]}"
done
echo ""

# Mostra os números ausentes
echo -n "Os números AUSENTES são: "
for i in $(seq $N_NUMBERS $((MAX_NUM - 1))); do
    printf "%02d " "${numbers[i]}"
done
echo ""
