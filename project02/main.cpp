#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#define SIZE 100

int A[SIZE];

sem_t reading, writing;

int randomNum()
{
  return random() / (RAND_MAX / 10);
}

void *Writer(void *args)
{
  int thread_num = *((int *)args);
  std::cout << "Writer " << thread_num << " started.\n";

  while (1)
  {
    int index = random() % SIZE;
    int value = randomNum();
    sem_wait(&reading);
    sem_wait(&writing);
    sem_post(&writing);
    A[index] = value;
    std::cout << "Writer " << thread_num << " wrote " << value << " into index " << index << ".\n";
    sleep(1);
  }

  return nullptr;
}

void *Reader(void *args)
{
  int thread_num = *((int *)args);
  std::cout << "Reader " << thread_num << " started.\n";

  while (1)
  {
    int index = random() % SIZE;
    sem_post(&reading);
    int value = A[index];
    sleep(1);
  }

  return nullptr;
}

int main()
{
  sem_init(&reading, 0, 0);
  sem_init(&writing, 0, 0);

  for (int i = 0; i < SIZE; i++)
  {
    A[i] = randomNum();
  }

  pthread_t writer[2], reader[4];
  int writers[2], readers[4];

  for (int i = 0; i < 2; i++)
  {
    writers[i] = i + 1;
    pthread_create(&writer[i], nullptr, Writer, (void *)(writers + i));
  }

  for (int i = 0; i < 4; i++)
  {
    readers[i] = i;
    pthread_create(&reader[i], nullptr, Reader, (void *)(readers + i));
  }

  int i = 0;

  Writer((void *)&i);

  return 0;
}