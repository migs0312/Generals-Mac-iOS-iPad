# Idempotently apply a patch to the DXVK source tree.
#
# Used as an ExternalProject PATCH_COMMAND, which re-runs whenever the source is
# re-cloned. Applying an already-applied patch is a hard error in git, so guard
# with a reverse-check first: if the patch reverse-applies cleanly the tree
# already carries it and there is nothing to do.
#
# Usage: cmake -DDXVK_SRC=<dir> -DDXVK_PATCH=<file> -P apply-dxvk-patch.cmake

if(NOT EXISTS "${DXVK_PATCH}")
  message(FATAL_ERROR "DXVK patch not found: ${DXVK_PATCH}")
endif()
if(NOT EXISTS "${DXVK_SRC}")
  message(FATAL_ERROR "DXVK source dir not found: ${DXVK_SRC}")
endif()

execute_process(
  COMMAND git -C "${DXVK_SRC}" apply --reverse --check "${DXVK_PATCH}"
  RESULT_VARIABLE DXVK_PATCH_ALREADY_APPLIED
  ERROR_QUIET)

if(DXVK_PATCH_ALREADY_APPLIED EQUAL 0)
  message(STATUS "DXVK macOS: ${DXVK_PATCH} already applied")
else()
  execute_process(
    COMMAND git -C "${DXVK_SRC}" apply "${DXVK_PATCH}"
    RESULT_VARIABLE DXVK_PATCH_RESULT)
  if(NOT DXVK_PATCH_RESULT EQUAL 0)
    message(FATAL_ERROR
      "Failed to apply ${DXVK_PATCH} to ${DXVK_SRC} — "
      "DXVK will not compile against Xcode 27 / libc++ 21 without it.")
  endif()
  message(STATUS "DXVK macOS: applied ${DXVK_PATCH}")
endif()
