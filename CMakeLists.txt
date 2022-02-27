include(CheckLanguage)
check_language(CUDA)

cmake_minimum_required(VERSION 3.10)

enable_language(CUDA)

project(
        CGOL
        VERSION 1.0
        LANGUAGES C CXX CUDA)

set(CMAKE_CXX_STANDARD 14)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ../bin)

add_executable(cgol 
        src/main.cpp
        kernel/kernel.cu
        )

target_include_directories(cgol
        PRIVATE
        ${PROJECT_SOURCE_DIR}/include)