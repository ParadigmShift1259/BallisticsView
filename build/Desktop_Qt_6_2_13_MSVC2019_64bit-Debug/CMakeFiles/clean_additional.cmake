# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appBallisticsView_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appBallisticsView_autogen.dir\\ParseCache.txt"
  "appBallisticsView_autogen"
  )
endif()
