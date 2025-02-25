cmake_minimum_required(VERSION 3.14)

set(CMAKE_CXX_STANDARD 17)
add_compile_definitions(UNICODE _UNICODE)

if(WIN7_SYSTEM_SUPPORT MATCHES ON)
	add_compile_definitions(_WIN32_WINNT=0x601)
endif()

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
file(COPY Shaders DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

aux_source_directory(. DIR_SRCS)
file(GLOB SHADER_FILES ${CMAKE_CURRENT_BINARY_DIR}/Shaders/*.hlsl ${CMAKE_CURRENT_BINARY_DIR}/Shaders/*.hlsli)
file(GLOB HEADER_FILES ./*.h)

foreach(SHADER_FILE ${SHADER_FILES})
	set_source_files_properties(${SHADER_FILE} PROPERTIES HEADER_FILE_ONLY TRUE)
endforeach()

add_executable(31_Shadow_Mapping WIN32 ${DIR_SRCS} ${HEADER_FILES} ${SHADER_FILES})

target_link_libraries(31_Shadow_Mapping d3d11.lib dxgi.lib dxguid.lib D3DCompiler.lib winmm.lib)

# Assimp
target_link_libraries(31_Shadow_Mapping assimp)
set_target_properties(31_Shadow_Mapping PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=${ASSIMP_LIBRARY_OUTPUT_DIRECTORY}/$<IF:$<CONFIG:Debug>,Debug,Release>")

# ImGui
target_link_libraries(31_Shadow_Mapping ImGui)
file(COPY imgui.ini DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

# Common
target_link_libraries(31_Shadow_Mapping Common)

source_group("Shaders" FILES ${SHADER_FILES})
set_target_properties(31_Shadow_Mapping PROPERTIES OUTPUT_NAME "31 Shadow Mapping")

set_target_properties(31_Shadow_Mapping PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(31_Shadow_Mapping PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(31_Shadow_Mapping PROPERTIES FOLDER "Project 19-")
