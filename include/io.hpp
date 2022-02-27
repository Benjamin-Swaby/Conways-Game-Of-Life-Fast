#include <vector>
#include <iostream>
#include <iterator>
#include <fstream>
#include <string>

namespace cgol {

    inline void read(std::string path, int *arr) {
        char ch;
        std::fstream fin(path, std::fstream::in);
        
        int x = 0;

        while (fin >> std::noskipws >> ch) {
            arr[x] = (int)ch - 48;
            x++;
        }

    }


    inline void write(std::string path, int *arr, size_t N) {
        std::ofstream output(path);

        for (int i = 0; i < N; i++) {
            output << arr[i];    
        }
    }
}