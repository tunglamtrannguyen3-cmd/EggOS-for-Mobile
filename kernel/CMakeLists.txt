add_library(kernel STATIC
    main.c
    init.c
)

target_include_directories(kernel PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/common/include
)

target_compile_options(kernel PRIVATE
    -fno-stack-protector
    -O2
)
