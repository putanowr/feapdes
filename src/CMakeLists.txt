add_custom_target(
  feapgptab ALL SOURCES feapgptab.sh 
)

add_custom_command(
  OUTPUT feapgptab.sh 
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/build.sh feapgptab_src.sh feapgptab.sh
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/feapgptab_src.sh
)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/feapgptab.sh
   DESTINATION ${PROJECT_VERSION}/bin RENAME feapgptab
)
