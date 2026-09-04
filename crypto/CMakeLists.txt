# Placeholder for crypto module
# Will integrate OpenSSL primitives and build custom crypto layer

add_library(crypto STATIC
    stub.c
)

target_include_directories(crypto PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
