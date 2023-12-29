cmake_minimum_required(VERSION 3.22.1)
project(ModernCPPBloom)


#[[ Depending on some CPU architectures, may need to align to more than one 
cache line to avoid false sharing for prefetched blocks, e.g., 
64 * 2 = 128 bytes. Also, the cache line size may not be 64 bytes, though it is on 
most CPU architectures.
]]
add_compile_definitions(ALIGN_NO_FALSE_SHARING=64)

set(ModernCPPBloom_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)

#

file(STRINGS "${ModernCPPBloom_INCLUDE_DIR}/bloom_filter.hpp" ModernCPPBloom_version_defines
     REGEX "#define ModernCPPBloom_VERSION_(MAJOR|MINOR|PATCH)")

foreach(ver ${ModernCPPBloom_version_defines})
    if(ver MATCHES "#define ModernCPPBloom_VERSION_(MAJOR|MINOR|PATCH) +([^ ]+)$")
        set(ModernCPPBloom_VERSION_${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" CACHE INTERNAL "")
    endif()
endforeach()

set(${PROJECT_NAME}_VERSION
    ${ModernCPPBloom_VERSION_MAJOR}.${ModernCPPBloom_VERSION_MINOR}.${ModernCPPBloom_VERSION_PATCH})
message(STATUS "ModernCPPBloom version ${${PROJECT_NAME}_VERSION}")

#

if(NOT MSVC)
    include(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("-std=c++20" COMPILER_SUPPORTS_CXX20)
    
    if(COMPILER_SUPPORTS_CXX20)
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has C++20 support.")
    else()
        message(FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER} "
            "ModernCPPBloom requires a C++20-compatible compiler.")
    endif()
endif()

# options. enable using cmake3 -DModernCPPBloom_BUILD_TESTS=ON

OPTION(ModernCPPBloom_BUILD_TESTS "ModernCPPBloom test suite" OFF)

# install

add_library(ModernCPPBloom INTERFACE)
include_directories(${CMAKE_SOURCE_DIR}/gcem/include)
target_include_directories(ModernCPPBloom INTERFACE $<BUILD_INTERFACE:${ModernCPPBloom_INCLUDE_DIR}>
                                          $<INSTALL_INTERFACE:include>)

if(ModernCPPBloom_BUILD_TESTS)
    add_subdirectory(tests)
endif()

#

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

install(
    TARGETS ModernCPPBloom
    EXPORT ${PROJECT_NAME}-targets
)

export(EXPORT ${PROJECT_NAME}-targets
       FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake")

install(DIRECTORY ${ModernCPPBloom_INCLUDE_DIR}/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

#

set(ModernCPPBloom_CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}" CACHE STRING "install path for ModernCPPBloomConfig.cmake")

configure_package_config_file(cmake_files/${PROJECT_NAME}Config.cmake.in
                              "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
                              INSTALL_DESTINATION ${ModernCPPBloom_CMAKECONFIG_INSTALL_DIR})

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
                                 VERSION ${${PROJECT_NAME}_VERSION}
                                 COMPATIBILITY SameMajorVersion)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
        DESTINATION ${ModernCPPBloom_CMAKECONFIG_INSTALL_DIR})

install(EXPORT ${PROJECT_NAME}-targets
        FILE ${PROJECT_NAME}Targets.cmake
        DESTINATION ${ModernCPPBloom_CMAKECONFIG_INSTALL_DIR})