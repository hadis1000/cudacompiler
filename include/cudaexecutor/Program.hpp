#ifndef CUDAEXECUTOR_PROGRAM_HPP_
#define CUDAEXECUTOR_PROGRAM_HPP_

#include <string>
#include <vector>

#include "Headers.hpp"
#include "Kernel.hpp"
#include "util.hpp"

#include <cuda.h>
#include <nvrtc.h>

namespace cudaexecutor {

class Program {
  Headers _headers;
  std::string _kernel_string;

public:
  explicit Program(std::string kernel_string, Headers headers = Headers());
  Kernel *kernel(std::string function_name);
};

class ProgramArg {
  void *_hdata;
  CUdeviceptr _ddata;
  bool _output;
  size_t _size;

public:
  ProgramArg(void *const data, size_t size, bool output = false);
  void upload();
  void download();
};

} // namespace cudaexecutor

#endif // CUDAEXECUTOR_PROGRAM_HPP_
