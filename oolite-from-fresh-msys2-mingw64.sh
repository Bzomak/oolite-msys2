#! /usr/bin/bash -x

###############################
#
# This script is for setting up a development environment for Oolite on MSYS2 MINGW64.
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It needs to be run from the root of the repository because it uses relative paths to find the build scripts for the dependencies and Oolite.
# It therefore needs the whole of the oolite-msys2 repository to be present in the MSYS2 MINGW64 environment.
# It will download everything that it needs to set up a development environment from a fresh MSYS2 install and build Oolite.
#
# Download and install MSYS2 from https://www.msys2.org/#installation
#
# Open MSYS2 MINGW64
#
# Update MSYS2 (May need to run twice. Not needed when using msys2/setup-msys2@v2 GitHub Action) by running the following command:
# pacman -Syu
#
###############################

# Usage function
usage() {
    echo "Usage: $(basename "$0") [-b BUILD_TYPE] [-r GIT_REF]"
    echo "Options:"
    echo "  -b BUILD_TYPE   Specify build type (default: release)"
    echo "  -r GIT_REF      Specify Git reference (default: master)"
    exit 1
}

# Validate build type
validate_build_type() {
    echo "Validating build type..."
    local build_type=$1
    case $build_type in
        release|release-snapshot|release-deployment|debug)
            ;;
        *)
            echo "Error: Invalid build type '$build_type'. Allowed values are release, release-snapshot, release-deployment, or debug." >&2
            usage
            ;;
    esac
}

# Validate git ref
validate_git_ref() {
    echo "Validating git ref..."
    local git_ref=$1
    if git ls-remote --exit-code https://github.com/OoliteProject/oolite.git "$git_ref"
    then
        echo "The reference $git_ref exists in the remote repository."
    else
        echo "The reference $git_ref does not exist in the remote repository." >&2
        usage
    fi
}

# Default values
BUILD_TYPE="release"
GIT_REF="master"

# Install git. It's not installed by default in MSYS2 MINGW64
pacman -S --noconfirm --needed git

# Parse command-line options
echo "Parsing any command-line options..."
while getopts ":b:r:" opt; do
    case ${opt} in
        b )
            echo "Want to validate build type..."
            validate_build_type "$OPTARG"
            BUILD_TYPE="$OPTARG"
            ;;
        r )
            echo "Want to validate git ref..."
            validate_git_ref "$OPTARG"
            GIT_REF="$OPTARG"
            ;;
        \? )
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" >&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))
echo "Parsing command line options complete."
echo "Build type set to: $BUILD_TYPE"
echo "Oolite git ref set to: $GIT_REF"

###############################

# Install build dependencies for GNUstep make
read -r -a TOOLS_MAKE_MSYS2_DEPS <<< "$(cat ./deps/tools-make/msys2-deps)"
pacman -S --noconfirm --needed "${TOOLS_MAKE_MSYS2_DEPS[@]}"

# Clone tools-make repo
TOOLS_MAKE_VERSION=$(cat ./deps/tools-make/version)
git clone https://github.com/gnustep/tools-make.git --branch="$TOOLS_MAKE_VERSION"

# Make and Install gmake
./deps/tools-make/build.sh
./deps/tools-make/install.sh

###############################

# Install build dependencies for GNUstep libs-base
read -r -a LIBS_BASE_MSYS2_DEPS <<< "$(cat ./deps/libs-base/msys2-deps)"
pacman -S --noconfirm --needed "${LIBS_BASE_MSYS2_DEPS[@]}"

# Clone libs-base repo - Needs https://github.com/gnustep/libs-base/pull/295
LIBS_BASE_VERSION=$(cat ./deps/libs-base/version)
git clone https://github.com/gnustep/libs-base.git
cd libs-base || exit 
git checkout "$LIBS_BASE_VERSION"
cd ..

# Make and install libs-base
./deps/libs-base/build.sh
./deps/libs-base/install.sh

###############################

# Install build dependencies for SDL
read -r -a SDL_MSYS2_DEPS <<< "$(cat ./deps/sdl/msys2-deps)"
pacman -S --noconfirm --needed "${SDL_MSYS2_DEPS[@]}"

# Download SDL and extract from tarball
SDL_VERSION=$(cat ./deps/sdl/version)
wget "$SDL_VERSION"
tar -xf SDL-1.2.13.tar.gz

# Make and install SDL
./deps/sdl/build.sh
./deps/sdl/install.sh

###############################

# Install build dependencies for Oolite
# Some of these are already installed, but we're reusing the list from the build Oolite job on GitHub Actions

read -r -a OOLITE_MSYS2_DEPS <<< "$(cat ./oolite-config/msys2-deps)"
pacman -S --noconfirm --needed "${OOLITE_MSYS2_DEPS[@]}"

# Clone Oolite repo and submodules
git clone --recursive https://github.com/OoliteProject/oolite.git --branch="$GIT_REF"

# Now let's try to compile Oolite
./oolite-config/build.sh "$BUILD_TYPE"

###############################
###############################
###############################
