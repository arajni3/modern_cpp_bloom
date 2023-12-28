#  ModernCPPBloom

A C++20 port of the C-based bloom filter implementation [barrust/bloom](https://github.com/barrust/bloom/). Like the latter, this library is header-only. C++ brings the power of template parameters and C++20 guarantees conditions for their values to be defined at compile time using consteval (as well as constinit, though the latter is not used here). 

This was originally defined in my [RingDB](https://github.com/arajni3r/ringdb) project but the value of a  bloom filter implementation in modern C++ stood out enough for it to become its own library. The underlying array in the bloom filter is aligned to avoid false sharing so that the bloom filter can be bootstrapped into any application that uses multiprocessing, such as RingDB. This implementation uses the gcem library for constexpr math functions, many of which will not be constexpr in the C++ standard until C++26.

This header-only library can be built using the build_bloom shell script contained in this project.
