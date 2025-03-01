project(validation_tools)
include(ExternalProject)

if (SUBPROJECT_INSTALL_PREFIX)
    set(_SUBPROJECT_INSTALL_PREFIX "${SUBPROJECT_INSTALL_PREFIX}")
else()
    set(_SUBPROJECT_INSTALL_PREFIX install)
endif()

set(TOOLCHAIN ${RISCV_TOOLCHAIN_PATH})
set(FLAGS "-ffreestanding -nostdinc -nodefaultlibs -nostdlib -Os -Wall -Werror -Wextra")
set(FLAGS "${FLAGS} -I${PLATFORM_FILES_ROOT}/include")
set(FLAGS "${FLAGS} -march=${SUPPORTED_RISCV_ARCH}")
ExternalProject_Add(
    libc
    CONFIGURE_COMMAND ""
    DEPENDS platform_headers
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libc"
    BUILD_ALWAYS True
    BUILD_COMMAND make
        -f "${CMAKE_CURRENT_SOURCE_DIR}/libc/Makefile"
        CFLAGS=${FLAGS}
        CC=${TOOLCHAIN}/bin/riscv32-unknown-elf-gcc
        AR=${TOOLCHAIN}/bin/riscv32-unknown-elf-ar
        INSTALL_DIR=${_SUBPROJECT_INSTALL_PREFIX}
        TOP=${CMAKE_CURRENT_SOURCE_DIR}/libc all install test_program VERBOSE=1
    INSTALL_COMMAND ""
)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/misc/testsMakefile.include.in"
               "${_SUBPROJECT_INSTALL_PREFIX}/share/testsMakefile.include")

