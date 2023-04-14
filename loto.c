#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_NUM 25
#define N_NUMBERS 15

int main()
{
    srand(time(NULL));
    int i, j, numbers[MAX_NUM];

    for (i = 0; i < MAX_NUM; i++)
    {
        numbers[i] = i + 1;
    }

    for (i = 0; i < N_NUMBERS; i++)
    {
        int randomIndex = rand() % (MAX_NUM - i) + i;
        int temp = numbers[i];
        numbers[i] = numbers[randomIndex];
        numbers[randomIndex] = temp;
    }

    printf("Os %d números aleatórios gerados são: \n", N_NUMBERS);
    for (i = 0; i < N_NUMBERS; i++)
    {
        printf("%d ", numbers[i]);
    }

    printf("\n");

    // Ordenando os números gerados de forma crescente
    for (i = 0; i < N_NUMBERS - 1; i++)
    {
        for (j = i + 1; j < N_NUMBERS; j++)
        {
            if (numbers[i] > numbers[j])
            {
                int temp = numbers[i];
                numbers[i] = numbers[j];
                numbers[j] = temp;
            }
        }
    }

    printf("Os números gerados e ordenados são: \n");
    for (i = 0; i < N_NUMBERS; i++)
    {
        printf("%d ", numbers[i]);
    }

    printf("\n");

    return 0;
}
