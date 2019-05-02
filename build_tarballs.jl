# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "pylon_julia_wrapper"

version = get(ENV, "TRAVIS_TAG", "")
if version == ""
    version = "v0.99.0"
end

sources = [
    "src"
]

pylon_version = "5.1.0.12682"
# pylon_sha1sum = "db866bea9d8a8273d8b85cc331fa77b95bae4c83"

# pylon_version = "5.2.0.13457"

pylon_macos_version = "5.1.1.13069"

basler_web_time_limit = round(Int, time()) + 24*60*60

# Bash recipe for building across all platforms
script = """
cd \$WORKSPACE/srcdir

mkdir downloads && cd downloads

if [[ \${target} == *linux* ]]; then
    curl https://www.baslerweb.com/fp-$basler_web_time_limit/media/downloads/software/pylon_software/pylon-$pylon_version-x86_64.tar.gz -O
    tar xfz pylon-$pylon_version-x86_64.tar.gz
    cd pylon-$pylon_version-x86_64
    tar xfz pylonSDK*.tar.gz

    export PYLON_INCLUDE_PATH=\$WORKSPACE/srcdir/downloads/pylon-$pylon_version-x86_64/pylon5/include
    export PYLON_LIB_PATH=\$WORKSPACE/srcdir/downloads/pylon-$pylon_version-x86_64/pylon5/lib64
elif [[ \${target} == *apple* ]]; then
    curl https://www.baslerweb.com/fp-$basler_web_time_limit/media/downloads/software/pylon_software/pylon-$pylon_macos_version.dmg -O
    apk update && apk add p7zip && apk add libarchive-tools
    7z x pylon-$pylon_macos_version.dmg
    mv \"pylon 5 Camera Software Suite\" pylon-$(pylon_macos_version)
    cd pylon-$(pylon_macos_version)
    7z x pylon-$pylon_macos_version.pkg
    gunzip -c pylonsdk.pkg/Payload | bsdcpio -i --no-preserve-owner
    mkdir include
    mv Library/Frameworks/pylon.framework/Versions/A/Headers include/pylon
    mv include/pylon/GenICam/* include/

    export PYLON_INCLUDE_PATH=\$WORKSPACE/srcdir/downloads/pylon-$pylon_macos_version/include
    export PYLON_LIB_PATH=\$WORKSPACE/srcdir/downloads/pylon-$pylon_macos_version/Library/Frameworks/pylon.framework/Libraries
fi
cd ../..

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/\$target/\$target.toolchain -DCMAKE_CXX_FLAGS="-march=x86-64" -DCMAKE_INSTALL_PREFIX=\$prefix -DCMAKE_FIND_ROOT_PATH=\$prefix -DJulia_PREFIX=\$prefix -DPYLON_INCLUDE_PATH=\${PYLON_INCLUDE_PATH} -DPYLON_LIB_PATH=\${PYLON_LIB_PATH} ..
VERBOSE=ON cmake --build . --config Release --target install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = Platform[]
_abis(p) = (:gcc7,:gcc8)
_archs(p) = (:x86_64, :i686)
_archs(::Type{Linux}) = (:x86_64,)
let p = Linux # Windows
    for a in _archs(p)
        for abi in _abis(p)
            push!(platforms, p(a, compiler_abi=CompilerABI(abi,:cxx11)))
        end
    end
end
push!(platforms, MacOS(:x86_64))

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "lib"*name, Symbol(name))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl",
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.1/build_libcxxwrap-julia-1.0.v0.5.1.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, VersionNumber(version), sources, script, platforms, products, dependencies)
