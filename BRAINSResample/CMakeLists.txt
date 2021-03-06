
##- project(BRAINSResample)

#-----------------------------------------------------------------------------
# Dependencies.
#

#
# ITK
#

FindITKUtil(BRAINSResample_ITK
  ITKDisplacementField
  ITKDistanceMap
  ITKImageFunction
  ITKImageGrid
  ITKImageIntensity
  ITKImageSources
  ITKImageStatistics
  ITKThresholding
  ITKTransform
  ITKImageCompare
  ITKTestKernel
)

#-----------------------------------------------------------------------------
# Output directories.
#

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/BRAINSResampleCommonLib.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/BRAINSResampleCommonLib.h
  )

set(ALL_PROGS_LIST
  BRAINSResample
  BRAINSResize
  )
foreach(prog ${ALL_PROGS_LIST})
  StandardBRAINSBuildMacro(NAME ${prog} TARGET_LIBRARIES BRAINSCommonLib )
endforeach()

### Add the Testing Subdirectory.
if(BUILD_TESTING AND NOT BRAINSTools_DISABLE_TESTING)
  add_subdirectory(TestSuite)
endif()
