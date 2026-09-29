# Idempotently apply a patch to the DXVK source tree.
#
# Used as an ExternalProject PATCH_COMMAND, which re-runs whenever the source is
# re-cloned. The forward check goes first because it answers the question that
# matters -- does this tree still contain the code the patch replaces? The
# reverse check only separates "already applied" from "no longer fits". Asking
# reverse first is unsafe: a fix that makes code identical to nearby code lets
# the reversed hunk match the neighbour, so an unpatched tree reads as patched.
#
# Usage: cmake -DDXVK_SRC=<dir> -DDXVK_PATCH=<file> -P apply-dxvk-patch.cmake

if(NOT EXISTS "${DXVK_PATCH}")
  message(FATAL_ERROR "DXVK patch not found: ${DXVK_PATCH}")
endif()
if(NOT EXISTS "${DXVK_SRC}")
  message(FATAL_ERROR "DXVK source dir not found: ${DXVK_SRC}")
endif()

execute_process(
  COMMAND git -C "${DXVK_SRC}" apply --check "${DXVK_PATCH}"
  RESULT_VARIABLE DXVK_PATCH_APPLIES
  ERROR_QUIET)

if(DXVK_PATCH_APPLIES EQUAL 0)
  execute_process(
    COMMAND git -C "${DXVK_SRC}" apply "${DXVK_PATCH}"
    RESULT_VARIABLE DXVK_PATCH_RESULT)
  if(NOT DXVK_PATCH_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to apply ${DXVK_PATCH} to ${DXVK_SRC}")
  endif()
  message(STATUS "DXVK macOS: applied ${DXVK_PATCH}")
else()
  execute_process(
    COMMAND git -C "${DXVK_SRC}" apply --reverse --check "${DXVK_PATCH}"
    RESULT_VARIABLE DXVK_PATCH_REVERSES
    ERROR_QUIET)
  if(DXVK_PATCH_REVERSES EQUAL 0)
    message(STATUS "DXVK macOS: ${DXVK_PATCH} already applied")
  else()
    message(FATAL_ERROR
      "${DXVK_PATCH} neither applies to nor reverses from ${DXVK_SRC}: the DXVK "
      "source no longer matches the commit this patch was written against. If the "
      "DXVK source now includes the upstream fix, delete this patch and its "
      "PATCH_COMMAND in cmake/dx8.cmake.")
  endif()
endif()
