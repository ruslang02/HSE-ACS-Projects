#include <iostream>
#include <fstream>
#include <sstream>
#include <pthread.h>

const int maxSize = 100;

struct ThreadData
{
  int *A;
  int *B;
  int *C;
  int lenA;
  int lenB;
  int lenC;
};

bool exists(int *array, int element)
{
  for (int i = 0; i < sizeof(array) / sizeof(int); i++)
  {
    if (*(array + i) == element)
      return true;
  }
  return false;
}

void *andProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;
  int lenA = sizeof(data->A) / sizeof(int), lenB = sizeof(data->B) / sizeof(int), lenC = sizeof(data->C) / sizeof(int);
  int andSet[data->lenA < data->lenB ? data->lenA : data->lenB];
  int index = 0;
  for (int i = 0; i < data->lenA; i++)
  {
    if (exists(data->A, data->B[i]))
      andSet[index++] = data->B[i];
  }
  for (int i = 0; i < data->lenB; i++)
  {
    if (exists(data->B, data->A[i]) && !exists(andSet, data->A[i]))
      andSet[index++] = data->A[i];
  }

  if (index != data->lenC)
  {
    return (void *)false;
  }
  return (void *)true;
}

void *orProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;

  int orSet[]
}

void *rcofAinBProcess(void *args) {
  ThreadData *data = (ThreadData *)args;
}

void *rcofBinAProcess(void *args) {
  ThreadData *data = (ThreadData *)args;
}

int main(int argc, char **argv)
{
  if (argc != 3)
  {
    std::cerr << "Not enough arguments.\n";
    return 1;
  }
  std::ifstream input(argv[1]);
  std::ofstream output(argv[2]);

  std::string line;
  int lenA, lenB, lenC;
  if (input.good() && std::getline(input, line))
  {
    std::istringstream(line) >> lenA >> lenB >> lenC;
  }
  else
  {
    std::cerr << "First line of the input file should contain the count of sets A, B and C.\n";
    return 1;
  }
  int A[lenA], B[lenB], C[lenC];
  if (input.good() && std::getline(input, line))
  {
    std::istringstream stream(line);
    for (int i = 0; i < lenA && stream >> A[i]; i++)
      ;
  }
  else
  {
    std::cerr << "Set A was not defined.\n";
    return 1;
  }

  if (input.good() && std::getline(input, line))
  {
    std::istringstream stream(line);
    for (int i = 0; i < lenB && stream >> B[i]; i++)
      ;
  }
  else
  {
    std::cerr << "Set B was not defined.\n";
    return 1;
  }

  if (input.good() && std::getline(input, line))
  {
    std::istringstream stream(line);
    for (int i = 0; i < lenC && stream >> C[i]; i++)
      ;
  }
  else
  {
    std::cerr << "Set C was not defined.\n";
    return 1;
  }

  pthread_t pth_and, pth_or, pth_subB, pth_subA;
  ThreadData data;
  data.A = A;
  data.B = B;
  data.C = C;
  data.lenA = lenA;
  data.lenB = lenB;
  data.lenC = lenC;
  pthread_create(&pth_and, NULL, andProcess, &data);
  for (int i = 0; i < sizeof(A) / sizeof(int); i++)
  {
    output << A[i] << " ";
  }

  return 0;
}