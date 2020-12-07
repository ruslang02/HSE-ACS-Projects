#include <iostream>
#include <pthread.h>
#include <semaphore.h>

sem_t reading, writing;

void * Writer(void * args) {
  std::cout << "Writer started.\n";
  
  return nullptr;
}

void * Reader(void * args) {
  std::cout << "Reader started.\n";

  return nullptr;
}

int main() {
  sem_init(&reading, 0, 0);
  sem_init(&writing, 0, 0);

  pthread_t writer, reader;

  pthread_create(&writer, nullptr, Writer, (void*) nullptr);
  pthread_create(&reader, nullptr, Reader, (void*) nullptr);

  return 0;
}