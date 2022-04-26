#env > env.txt
#instruments -s devices > devices.txt
#! /bin/sh -e
# This script demonstrates archive and create action on frameworks and libraries
# Based on script by @author Boris Bielik

# 工程是否是.a静态库
PROJECT_STATIC_LIBRARY=false
# 工程是否是workspace
PROJECT_WORKSPACE=true
# 是否编译macOS版本
BUILD_MACOS=true
# 编译完成时，打开输出文件夹
REVEAL_XCFRAMEWORK_IN_FINDER=true

# Release dir path
OUTPUT_DIR_PATH="${PROJECT_DIR}/XCFramework"

function archivePathSimulator {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-SIMULATOR"
  echo "${DIR}"
}

function archivePathDevice {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-DEVICE"
  echo "${DIR}"
}

function archivePathMaccatalyst {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-MACOS"
  echo "${DIR}"
}

# Archive takes 3 params
#
# 1st == SCHEME
# 2nd == destination
# 3rd == archivePath
# workspace和project二选一
#-project "${PROJECT_NAME}.xcodeproj" \
#-workspace "${PROJECT_NAME}.xcworkspace" \

function archive {
    echo "▸ Starts archiving the scheme: ${1} for destination: ${2};"
    echo "▸ Archive path: ${3}.xcarchive"
    if [ ${PROJECT_WORKSPACE} = true ]; then

      xcodebuild clean archive \
          -workspace "${PROJECT_NAME}.xcworkspace" \
          -scheme ${1} \
          -configuration ${CONFIGURATION} \
          -destination "${2}" \
          -archivePath "${3}" \
          SKIP_INSTALL=NO \
          OBJROOT="${OBJROOT}/DependentBuilds" \
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

    else

      xcodebuild clean archive \
          -project "${PROJECT_NAME}.xcodeproj" \
          -scheme ${1} \
          -configuration ${CONFIGURATION} \
          -destination "${2}" \
          -archivePath "${3}" \
          SKIP_INSTALL=NO \
          OBJROOT="${OBJROOT}/DependentBuilds" \
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

    fi
}

# Builds archive for iOS simulator 
 device
function buildArchive {

  # https://www.mokacoding.com/blog/xcodebuild-destination-options/
  # Platform                  Destination
  # iOS                   generic/platform=iOS
  # iOS Simulator         generic/platform=iOS Simulator
  # macOS                 generic/platform=macOS
  # tvOS                  generic/platform=tvOS
  # watchOS               generic/platform=watchOS
  # watchOS Simulator     generic/platform=watchOS Simulator
  # carPlayOS             generic/platform=carPlayOS
  # carPlayOS Simulator   generic/platform=carPlayOS Simulator

  SCHEME=${1}

  archive $SCHEME "generic/platform=iOS Simulator" $(archivePathSimulator $SCHEME)
  archive $SCHEME "generic/platform=iOS" $(archivePathDevice $SCHEME)
  if [ ${BUILD_MACOS} = true ]; then
    archive $SCHEME "generic/platform=macOS" $(archivePathMaccatalyst $SCHEME)
  fi
}

# Creates xc framework
function createXCFramework {
  FRAMEWORK_ARCHIVE_PATH_POSTFIX=".xcarchive/Products/Library/Frameworks"
  FRAMEWORK_SIMULATOR_DIR="$(archivePathSimulator $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  FRAMEWORK_DEVICE_DIR="$(archivePathDevice $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  FRAMEWORK_MACCATALYST_DIR="$(archivePathMaccatalyst $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"

  if [ ${BUILD_MACOS} = true ]; then

    xcodebuild -create-xcframework \
              -framework ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework \
              -framework ${FRAMEWORK_DEVICE_DIR}/${1}.framework \
              -framework ${FRAMEWORK_MACCATALYST_DIR}/${1}.framework \
              -output ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework
  else

    xcodebuild -create-xcframework \
              -framework ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework \
              -framework ${FRAMEWORK_DEVICE_DIR}/${1}.framework \
              -output ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework

  fi
}

### Static Libraries cant be turned into frameworks
function createXCFrameworkForStaticLibrary {

  LIBRARY_ARCHIVE_PATH_POSTFIX=".xcarchive/Products/usr/local/lib"
  LIBRARY_SIMULATOR_DIR="$(archivePathSimulator $1)${LIBRARY_ARCHIVE_PATH_POSTFIX}"
  LIBRARY_DEVICE_DIR="$(archivePathDevice $1)${LIBRARY_ARCHIVE_PATH_POSTFIX}"
  LIBRARY_MACCATALYST_DIR="$(archivePathMaccatalyst $1)${LIBRARY_ARCHIVE_PATH_POSTFIX}"

  xcodebuild -create-xcframework \
            -library ${LIBRARY_SIMULATOR_DIR}/lib${1}.a \
            -library ${LIBRARY_DEVICE_DIR}/lib${1}.a \
            -library ${LIBRARY_MACCATALYST_DIR}/lib${1}.a \
            -output ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework
}

echo "#####################"
echo "▸ Cleaning the dir: ${OUTPUT_DIR_PATH}"
rm -rf $OUTPUT_DIR_PATH


if [ ${PROJECT_STATIC_LIBRARY} = true ]; then

  #### Static Library ####
  LIBRARY="${PROJECT_NAME}"

  echo "▸ Archive $LIBRARY"
  buildArchive ${LIBRARY}

  echo "▸ Create $FRAMEWORK.xcframework"
  createXCFrameworkForStaticLibrary ${LIBRARY}

else

  #### Dynamic Framework ####
  DYNAMIC_FRAMEWORK="${PROJECT_NAME}"

  echo "▸ Archive $DYNAMIC_FRAMEWORK"
  buildArchive ${DYNAMIC_FRAMEWORK}

  echo "▸ Create $DYNAMIC_FRAMEWORK.xcframework"
  createXCFramework ${DYNAMIC_FRAMEWORK}
fi

if [ ${REVEAL_XCFRAMEWORK_IN_FINDER} = true ]; then
    open "${OUTPUT_DIR_PATH}/xcframeworks"
fi
