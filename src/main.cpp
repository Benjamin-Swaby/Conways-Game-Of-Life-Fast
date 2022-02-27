#include <iostream>
#include <vector>
#include <chrono>

#include "io.hpp"
#include "kernel.cuh"

using namespace std::chrono;

int main(int argc, char *argv[]) {


    int size = atoi(argv[1]);
    int generations = atoi(argv[2]);
    int save = atoi(argv[3]);

    printf("Allocating %ld KB\r\n", (sizeof(int) * size)/1000);
    int *board = new int [size];

    printf("Reading from ./map.mp\n\r");
    cgol::read("./map.mp", board);

    auto start = high_resolution_clock::now();

    cgol::conways_game_of_life(board, size, generations,save);

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<milliseconds>(stop - start);

    std::cout << "Total : " <<duration.count() << "ms" << std::endl;
    std::cout << "Av per gen : " << duration.count() / generations << "ms" << std::endl;

    return 0;
}