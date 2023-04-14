#!/bin/bash

# Inicializa variáveis
numeros=()
numeros_ord=()

# Lê os 5 números do usuário e adiciona cada um na array 'numeros'
for i in {1..5}; do
  echo "Digite o ${i}º número:"
  read -r numero
  numeros+=("$numero")
done

# Ordena os números em ordem crescente usando o método de ordenação por inserção
for numero in "${numeros[@]}"; do
  for (( i=0; i<${#numeros_ord[@]}; i++ )); do
    if (( numero < numeros_ord[i] )); then
      numeros_ord=("${numeros_ord[@]:0:i}" "$numero" "${numeros_ord[@]:i}")
      break
    fi
  done
  if (( ${#numeros_ord[@]} == 0 || numero >= numeros_ord[${#numeros_ord[@]}-1] )); then
    numeros_ord+=("$numero")
  fi
done

# Mostra os números ordenados na tela
echo "Números em ordem crescente: {numeros_ord[@]}"

# Calcula e mostra a soma dos números
soma=0
for numero in "${numeros_ord[@]}"; do
  soma=$((soma + numero))
done
echo "A soma dos números é: $soma"