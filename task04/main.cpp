#include <iostream>
#include <fstream>
#include <sstream>
#include <omp.h>

struct ThreadData
{
  int *A;
  int *B;
  int *C;
  int lenA;
  int lenB;
  int lenC;
};

bool checkArray(int *arr1, int arr1len, int *arr2, int arr2len)
{
  if (arr1len != arr2len)
    return false;

  bool abort = false;
#pragma omp parallel for
  for (int i = 0; i < arr1len; i++) {
    if (!abort && arr1[i] != arr2[i])
      abort = true;
  }
  return !abort;
}

bool andProcess(ThreadData *data)
{
  int *A = data->A;
  int *B = data->B;
  int *C = data->C;
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

  return checkArray(AND, index, C, lenC);
}

bool orProcess(ThreadData *data)
{
  int *A = data->A;
  int *B = data->B;
  int *C = data->C;
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
        OR[index] = B[j];
        index++;
      }
      j++;
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

  return checkArray(OR, index, C, lenC);
}

bool rcofAinBProcess(ThreadData *data)
{
  int *A = data->A;
  int *B = data->B;
  int *C = data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int AinB[lenB];
  int index = 0;

#pragma omp parallel for
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

  return checkArray(AinB, index, C, lenC);
}

bool rcofBinAProcess(ThreadData *data)
{
  int *A = data->A;
  int *B = data->B;
  int *C = data->C;
  int lenA = data->lenA;
  int lenB = data->lenB;
  int lenC = data->lenC;
  int BinA[lenB];
  int index = 0;

#pragma omp parallel for
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

  return checkArray(BinA, index, C, lenC);
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
  bool andResult, orResult, ainbResult, binaResult;
#pragma omp parallel sections shared(data, andResult, orResult, ainbResult, binaResult)
  {
#pragma omp section
    andResult = andProcess(&data);

#pragma omp section
    orResult = orProcess(&data);

#pragma omp section
    ainbResult = rcofAinBProcess(&data);

#pragma omp section
    binaResult = rcofBinAProcess(&data);
  }

  output << "C is " << (andResult ? "" : "NOT ")
         << "an intersection of sets A and B\n"
         << "C is " << (orResult ? "" : "NOT ")
         << "a union of sets A and B\n"
         << "C is " << (ainbResult ? "" : "NOT ")
         << "a relative complement of A in B\n"
         << "C is " << (binaResult ? "" : "NOT ")
         << "a relative complement of B in A";

  input.close();
  output.close();
  
  return 0;
}