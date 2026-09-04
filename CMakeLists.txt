cmake_minimum_required(VERSION 3.20)
project(EggOS
    VERSION 0.0.1
    LANGUAGES C ASM
    DESCRIPTION "The OS for mobile - ARM64 Edition"
)

# Configuration
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# ARM64 specific flags
set(CMAKE_C_FLAGS_INIT "-march=armv8-a -mcpu=generic -fPIC -fno-builtin")
set(CMAKE_ASM_FLAGS_INIT "-march=armv8-a")

# Build type defaults
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Compiler warnings
if(MSVC)
    add_compile_options(/Wall /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# Subdirectories
add_subdirectory(bootloader)
add_subdirectory(kernel)
add_subdirectory(crypto)

# Print configuration
message(STATUS "EggOS ${PROJECT_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Target: ARM64")
