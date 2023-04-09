#!/bin/bash

# Define a função para a leitura dos números com verificação de erro
function ler_numero {
    read -p "Digite um número: " var

    while ! [[ "$var" =~ ^[0-9]+$ ]]
    do
        echo "ERRO: Digite um número válido"
        read -p "Digite um número: " var
    done

    echo $var
}

# Pede ao usuário para inserir os números
num1=$(ler_numero)
num2=$(ler_numero)

# Encontra o MMC
mmc=0
while [ $mmc -eq 0 ]
do
    if [ $num1 -gt $num2 ]
    then
        maior=$num1
    else
        maior=$num2
    fi

    for (( i=maior; ; i++ ))
    do
        if (( $i % $num1 == 0 )) && (( $i % $num2 == 0 ))
        then
            mmc=$i
            break
        fi
    done
done

# Exibe o resultado
echo "O MMC de $num1 e $num2 é: $mmc"
