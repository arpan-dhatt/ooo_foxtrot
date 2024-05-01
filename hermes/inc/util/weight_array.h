#ifndef WEIGHT_ARRAY_H
#define WEIGHT_ARRAY_H

#include <vector>
#include <cstdint>

class weight_array_t {
public:
    uint32_t size;
    std::vector<float> array;

    weight_array_t(uint32_t _size) : 
        size(_size), 
        array(std::vector<float>(_size, 0.0f)) {}

    ~weight_array_t() {}
};

#endif
