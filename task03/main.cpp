#include <iostream>
#include <fstream>
#include <sstream>
#include "pthread.h"

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

bool exists(int *array, int element, int arrLength)
{
  for (int i = 0; i < arrLength; i++)
  {
    std::cout << array[i] << "=" << element << " ";
    if (array[i] == element)
      return true;
  }
  return false;
}

void *andProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;
  int *A = (int *)data->A;
  int *B = (int *)data->B;
  int *C = (int *)data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int AND[lenA > lenB ? lenA : lenB];
  int index = 0, i = 0, j = 0;
  while (i < lenA && j < lenB)
  {
    if (A[i] == B[j])
    {
      if (index == 0 || AND[index - 1] != A[i])
      {
        AND[index] = A[i];
        index++;
      }
      i++;
      j++;
    }
    else if (A[i] < B[j])
      i++;
    else
      j++;
  }

  if (index != lenC)
    return (void *)false;

  for (int i = 0; i < index; i++)
    if (AND[i] != C[i])
      return (void *)false;

  return (void *)true;
}

void *orProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;
  int *A = (int *)data->A;
  int *B = (int *)data->B;
  int *C = (int *)data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int OR[lenA + lenB];
  int index = 0, i = 0, j = 0;
  while (i < lenA && j < lenB)
  {
    if (A[i] < B[j])
    {
      if (OR[index - 1] != A[i])
      {
        OR[index] = A[i];
        index++;
      }
      i++;
    }
    else if (B[j] < A[i])
    {
      if (OR[index - 1] != B[j])
      {
        OR[index] = B[j];
        index++;
      }
      j++;
    }
    else
    {
      if (OR[index - 1] != B[j])
      {
        OR[index] = B[j++];
        index++;
      }
      i++;
    }
  }
  while (i < lenA)
  {
    if (OR[index - 1] != A[i])
    {
      OR[index] = A[i];
      index++;
    }
    i++;
  }
  while (j < lenB)
  {
    if (OR[index - 1] != B[j])
    {
      OR[index] = B[j];
      index++;
    }
    j++;
  }

  if (index != lenC)
    return (void *)false;

  for (int i = 0; i < index; i++)
    if (OR[i] != C[i])
      return (void *)false;

  return (void *)true;
}

void *rcofAinBProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;
  int *A = (int *)data->A;
  int *B = (int *)data->B;
  int *C = (int *)data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int AinB[lenB];
  int index = 0;
  for (int i = 0; i < lenB; i++)
  {
    bool flag = false;
    for (int j = 0; j < lenA; j++)
    {
      if (A[j] == B[i])
        flag = true;
    }
    if (!flag && AinB[index - 1] != B[i])
      AinB[index++] = B[i];
  }

  if (index != lenC)
    return (void *)false;

  for (int i = 0; i < index; i++)
    if (AinB[i] != C[i])
      return (void *)false;

  return (void *)true;
}

void *rcofBinAProcess(void *args)
{
  ThreadData *data = (ThreadData *)args;
  int *A = (int *)data->A;
  int *B = (int *)data->B;
  int *C = (int *)data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int BinA[lenB];
  int index = 0;
  for (int i = 0; i < lenA; i++)
  {
    bool flag = false;
    for (int j = 0; j < lenB; j++)
    {
      if (B[j] == A[i])
        flag = true;
    }
    if (!flag && BinA[index - 1] != A[i])
      BinA[index++] = A[i];
  }

  if (index != lenC)
    return (void *)false;

  for (int i = 0; i < index; i++)
    if (BinA[i] != C[i])
      return (void *)false;

  return (void *)true;
}

int inputSet(std::string line, int *set, int size)
{
  std::istringstream stream(line);
  for (int i = 0; i < size; i++)
  {
    if (!stream.good())
      return 1;
    int tmp;
    stream >> tmp;
    if (i != 0 && set[i - 1] > tmp)
    {
      std::cerr << "Set must be sorted.\n";
      return 1;
    }
    set[i] = tmp;
  }
  return 0;
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
    if (lenA <= 0 || lenB <= 0 || lenC <= 0)
    {
      std::cerr << "Set cannot be empty.\n";
      return 1;
    }
    if (lenA > 1000 || lenB > 1000 || lenC > 1000)
    {
      std::cerr << "Set cannot contain more than 1000 elements.\n";
      return 1;
    }
  }
  else
  {
    std::cerr << "First line of the input file should contain the count of sets A, B and C.\n";
    return 1;
  }
  int A[lenA], B[lenB], C[lenC];

  if (input.good() && std::getline(input, line) && !inputSet(line, A, lenA))
    std::cout << "Set A loaded.\n";
  else
  {
    std::cerr << "Invalid data given to set A.\n";
    return 1;
  }
  if (input.good() && std::getline(input, line) && !inputSet(line, B, lenB))
    std::cout << "Set B loaded.\n";
  else
  {
    std::cerr << "Invalid data given to set B.\n";
    return 1;
  }

  if (input.good() && std::getline(input, line) && !inputSet(line, C, lenC))
    std::cout << "Set C loaded.\n";
  else
  {
    std::cerr << "Invalid data given to set C.\n";
    return 1;
  }

  ThreadData data;
  data.A = A;
  data.B = B;
  data.C = C;
  data.lenA = lenA;
  data.lenB = lenB;
  data.lenC = lenC;

  pthread_t thread_and, thread_or, thread_ainb, thread_bina;
  pthread_create(&thread_and, nullptr, andProcess, (void *)&data);
  pthread_create(&thread_or, nullptr, orProcess, (void *)&data);
  pthread_create(&thread_ainb, nullptr, rcofAinBProcess, (void *)&data);
  pthread_create(&thread_bina, nullptr, rcofBinAProcess, (void *)&data);

  bool andResult, orResult, ainbResult, binaResult;
  pthread_join(thread_and, (void **)&andResult);
  pthread_join(thread_or, (void **)&orResult);
  pthread_join(thread_ainb, (void **)&ainbResult);
  pthread_join(thread_bina, (void **)&binaResult);

  output << "C is " << (andResult ? "" : "NOT ")
         << "an intersection of sets A and B\n"
         << "C is " << (orResult ? "" : "NOT ")
         << "a union of sets A and B\n"
         << "C is " << (ainbResult ? "" : "NOT ")
         << "a relative complement of A in B\n"
         << "C is " << (binaResult ? "" : "NOT ")
         << "a relative complement of B in A";

  return 0;
}