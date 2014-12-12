CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)
CMAKE_POLICY(VERSION 2.6)

FILE(GLOB src *.cc *.h)
FILE(GLOB luasrc *.lua)
SET(luasrc ${luasrc} alewrap.inl)

MESSAGE(STATUS "CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "TORCH_INSTALL_PREFIX ${TORCH_INSTALL_PREFIX}")
MESSAGE(STATUS "LUAROCKS_INSTALL_PREFIX ${LUAROCKS_INSTALL_PREFIX}")

IF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    MESSAGE(STATUS "Using Clang")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")        ## Optimize
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftemplate-depth=1024")
    MESSAGE(STATUS "FLAGS ${CMAKE_CXX_FLAGS}")
# Using GCC.
ELSEIF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    MESSAGE(STATUS "Using GCC")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")        ## Optimize
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")        ## Optimize
    MESSAGE(STATUS "FLAGS ${CMAKE_CXX_FLAGS}")
# Using Intel C++.
ELSEIF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
    MESSAGE(STATUS "Using Intel C++")
# Using Visual Studio C++.
ELSEIF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    MESSAGE(STATUS "Using Visual Studio C++")
ENDIF()


# We are building alewraplib.
# We specify the paths to ALE includes and libale.
# INCLUDE_DIRECTORIES(${Torch_SOURCE_INCLUDES})
find_path(XITARI_INCLUDE_DIR xitari/ale_interface.hpp
          HINTS 
          ${TORCH_INSTALL_PREFIX}/include
          ${CMAKE_INSTALL_PREFIX}/include
          ${CMAKE_INSTALL_PREFIX}/../../../../../include
          ${LUAROCKS_INSTALL_PREFIX}/../../../../../include
          PATH_SUFFIXES include)

find_path(XITARI_LIBRARY_DIR NAMES xitari libxitari.a
          HINTS 
          ${TORCH_INSTALL_PREFIX}/lib 
          ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/../../../../../lib 
          ${LUAROCKS_INSTALL_PREFIX}/../../../../../lib)

find_library(XITARI_LIBRARY NAMES xitari libxitari.a
          HINTS 
          ${TORCH_INSTALL_PREFIX}/lib 
          ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/../../../../../lib 
          ${LUAROCKS_INSTALL_PREFIX}/../../../../../lib)

IF(NOT(XITARI_INCLUDE_DIR))
  MESSAGE(ERROR "Could not find Xitari include location")
ENDIF()

IF(NOT(XITARI_LIBRARY_DIR))
  MESSAGE(ERROR "Could not find Xitari library")
ENDIF()

IF(NOT(XITARI_LIBRARY))
  MESSAGE(ERROR "Could not find Xitari library")
ENDIF()

SET(INCDIR "${XITARI_INCLUDE_DIR}")
SET(LIBDIR "${XITARI_LIBRARY_DIR}")

INCLUDE_DIRECTORIES("${INCDIR}")
LINK_DIRECTORIES("${LIBDIR}")

ADD_TORCH_PACKAGE(alewrap "${src}" "${luasrc}" "ALE Wrapper")
TARGET_LINK_LIBRARIES(alewrap ${XITARI_LIBRARY})

# INCLUDE_DIRECTORIES(../../xiborg/xitari)
# LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../xiborg/xitari/build)
# ADD_LIBRARY(alewraplib SHARED ${libsrc})
# TARGET_LINK_LIBRARIES(alewraplib xitari z)
