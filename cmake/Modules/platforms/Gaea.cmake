macro (setGaea)

  message("Setting flags and paths for Cray")
  set(HOST_FLAG "-xHOST" CACHE INTERNAL "Host Flag")
  set(MKL_FLAG "" CACHE INTERNAL "MKL flag" )
  set(GSI_Intel_Platform_FLAGS "-DPOUND_FOR_STRINGIFY -fp-model strict -assume byterecl -convert big_endian -implicitnone -D_REAL8_ ${OpenMP_Fortran_FLAGS} ${MPI_Fortran_COMPILE_FLAGS} -O3" CACHE INTERNAL "")
  set(ENKF_Platform_FLAGS "-O3 -fp-model strict -convert big_endian -assume byterecl -implicitnone  -DGFS -D_REAL8_ ${OpenMP_Fortran_FLAGS} " CACHE INTERNAL "")
  set(GSI_LDFLAGS "${OpenMP_Fortran_FLAGS}" CACHE INTERNAL "")
  find_package(HDF5 COMPONENTS C HL Fortran_HL REQUIRED )
  set(HDF5_USE_STATIC_LIBRARIES "ON" CACHE INTERNAL "HDF5_Static" )
  set(BUILD_CORELIBS "OFF" )
endmacro()