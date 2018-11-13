#include "jlcxx/jlcxx.hpp"

#include <pylon/PylonIncludes.h>

JLCXX_MODULE define_pylon_wrapper(jlcxx::Module& module)
{
  using namespace Pylon;

  module.method("get_pylon_version", []()
  {
    unsigned int major, minor, subminor, build;
    GetPylonVersion(&major, &minor, &subminor, &build);
    return std::make_tuple(major, minor, subminor, build);
  });
  module.method("get_pylon_version_string", &GetPylonVersionString);
  module.method("pylon_initialize", &PylonInitialize);
  module.method("pylon_terminate", &PylonTerminate);
}
