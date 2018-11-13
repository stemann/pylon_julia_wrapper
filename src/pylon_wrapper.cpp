#include "jlcxx/jlcxx.hpp"

#include <pylon/PylonIncludes.h>

JLCXX_MODULE define_pylon_wrapper(jlcxx::Module& module)
{
  using namespace Pylon;

  module.method("pylon_initialize", &PylonInitialize);
  module.method("pylon_terminate", &PylonTerminate);
}
