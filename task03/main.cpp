#include <iostream>
#include <fstream>
#include <sstream>

const int maxSize = 100;

int A[maxSize];
int B[maxSize];
int C[maxSize];

int main(int argc, char** argv) {
    if (argc != 3) {
        std::cerr << "Not enough arguments.\n";
        return 1; 
    }
    std::ifstream input(argv[1]);
    std::ofstream output(argv[2]);

    int * element = A;
    std::string line;
    while (input.good() && std::getline(input, line)) {
        std::istringstream stream(line);
        while(stream.good()) {
            stream >> *element;
            element++;
        }
        if (element < B) element = B;
        else if (element < C) element = C;
    }
    for (int i = 0; i < maxSize; i++)
    {
        output << A[i] << " ";
    }
    
    return 0;
}