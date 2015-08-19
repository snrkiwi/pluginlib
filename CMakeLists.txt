cmake_minimum_required(VERSION 2.8.3)

project(pluginlib)

if(NOT WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra")
endif()

find_package(ament_cmake REQUIRED)
find_package(ament_index_cpp REQUIRED)
find_package(class_loader REQUIRED)

find_package(Boost REQUIRED COMPONENTS filesystem system)
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
find_package(TinyXML REQUIRED)

ament_export_dependencies(ament_index_cpp class_loader TinyXML)
ament_export_include_directories(include)

add_executable(plugin_tool src/plugin_tool.cpp)
target_include_directories(plugin_tool PUBLIC
  include
  ${ament_index_cpp_INCLUDE_DIRS} ${class_loader_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS} ${TinyXML_INCLUDE_DIRS})
target_link_libraries(plugin_tool
  ${ament_index_cpp_LIBRARIES} ${class_loader_LIBRARIES}
  ${Boost_LIBRARIES} ${TinyXML_LIBRARIES})

if(AMENT_ENABLE_TESTING)
  find_package(ament_cmake_gtest REQUIRED)

  add_library(test_plugins EXCLUDE_FROM_ALL SHARED test/test_plugins.cpp)
  target_include_directories(test_plugins PUBLIC
    include
    ${ament_index_cpp_INCLUDE_DIRS} ${class_loader_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS} ${TinyXML_INCLUDE_DIRS})
  # place the library in an FHS compliant layout in the build space
  set(prefix "${CMAKE_CURRENT_BINARY_DIR}/prefix")
  set_target_properties(
    test_plugins PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${prefix}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${prefix}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${prefix}/bin")
  # place the plugin manifest in an FHS compliant layout in the build space
  file(COPY test/test_plugins.xml DESTINATION "${prefix}/share/pluginlib/test")
  # create an entry in the ament index for the exported plugins
  file(WRITE "${prefix}/share/ament_index/resource_index/pluginlib__plugin/pluginlib"
    "\${prefix}/test/test_plugins.xml\n")

  set(PLUGINLIB_TEST_PREFIX_PATH "${prefix}")
  configure_file(
    test/utest.cpp.in
    utest.cpp
    @ONLY)

  ament_add_gtest(${PROJECT_NAME}_utest
    ${CMAKE_CURRENT_BINARY_DIR}/utest.cpp SKIP_LINKING_MAIN_LIBRARIES)
  if(TARGET ${PROJECT_NAME}_utest)
    target_include_directories(${PROJECT_NAME}_utest PUBLIC
      include test
      ${ament_index_cpp_INCLUDE_DIRS} ${class_loader_INCLUDE_DIRS}
      ${Boost_INCLUDE_DIRS} ${TinyXML_INCLUDE_DIRS})
    target_link_libraries(${PROJECT_NAME}_utest
      ${ament_index_cpp_LIBRARIES} ${class_loader_LIBRARIES}
      ${Boost_LIBRARIES} ${TinyXML_LIBRARIES})
    add_dependencies(${PROJECT_NAME}_utest test_plugins)
  endif()
endif()

set(pluginlib_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(pluginlib-extras.cmake)

ament_package(
  CONFIG_EXTRAS "pluginlib-extras.cmake"
)

install(TARGETS plugin_tool ${PROJECT_NAME}_utest test_plugins
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

install(DIRECTORY cmake
  DESTINATION share/${PROJECT_NAME})

install(DIRECTORY include/pluginlib
  DESTINATION include)

install(DIRECTORY test
  DESTINATION include
  PATTERN "*.h")

install(FILES share/${PROJECT_NAME}/typed_class_loader_template.cpp
  DESTINATION share/${PROJECT_NAME})
