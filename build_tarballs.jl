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

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_CXX_FLAGS="-march=x86-64" -DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_FIND_ROOT_PATH=${prefix} -DJulia_PREFIX=${prefix} ..
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
# push!(platforms, MacOS(:x86_64))

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