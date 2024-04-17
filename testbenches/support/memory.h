#pragma once

#include <cstdint>
#include <deque>
#include <optional>
#include <string>
#include <utility>
#include <vector>

class Memory {
private:
    size_t latency;        ///< Fixed latency of memory accesses in cycles
    std::deque<std::pair<uint64_t, uint64_t>> read_queue;  ///< Queue of pending read requests

public:
    Memory(size_t size, size_t latency);
    ~Memory();

    uint8_t* data;         ///< Pointer to the memory data buffer
    size_t size;           ///< Size of the memory in bytes
    void load_memory(const std::string& file_path);
    void load_elf(const std::string& file_path);
    void write(uint64_t addr, uint64_t value);
    void read(uint64_t addr);
    void update();
    std::optional<uint64_t> get_read_data();
    void compare_with_file(const std::string& file_path);

private:
    void compare_values(uint64_t addr, const std::vector<uint64_t>& values);
};