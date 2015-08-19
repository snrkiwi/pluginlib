# Copyright 2015 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# collect all exported plugin xml files with the package name defining the interface
set(_package_names)
set(_plugin_xml_files)
foreach(export_tag ${${PROJECT_NAME}_EXPORT_TAGS})
  # TODO make the pattern more flexible
  string(REGEX MATCH "^<([a-z0-9_]+)[ \t\n\r]+plugin=\"([^\"]+)\".*>$" _match "${export_tag}")
  if(_match)
    message(STATUS "Found plugin(s) for package '${CMAKE_MATCH_1}': ${CMAKE_MATCH_2}")
    list(APPEND _package_names "${CMAKE_MATCH_1}")
    list(APPEND _plugin_xml_files "${CMAKE_MATCH_2}")
  endif()
endforeach()

# get unique package names and create an empty content variable for each
set(_unique_package_names ${_package_names})
if(DEFINED _unique_package_names)
  list(REMOVE_DUPLICATES _unique_package_names)
endif()
foreach(_package_name ${_unique_package_names})
  set(_resource_lines_${_package_name})
endforeach()

# collect content for each resource
set(_index 0)
while(TRUE)
  list(LENGTH _package_names _length)
  if(NOT _index LESS _length)
    break()
  endif()
  list(GET _package_names ${_index} _package_name)
  list(GET _plugin_xml_files ${_index} _plugin_xml_file)
  list(APPEND _resource_lines_${_package_name} "${_plugin_xml_file}\n")
  math(EXPR _index "${_index} + 1")
endwhile()

# create resource with all plugin xml files
foreach(_package_name ${_unique_package_names})
  ament_index_register_resource(
    "${_package_name}__plugin"
    CONTENT "${_resource_lines_${_package_name}}")
endforeach()
