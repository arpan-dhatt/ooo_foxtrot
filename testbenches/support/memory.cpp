#include "memory.h"

#include <iostream>
#include <fstream>
#include <cstring>

Memory::Memory(size_t size, size_t latency)
        : size(size), latency(latency) {
    data = new uint8_t[size];
    std::memset(data, 0, size);
}

Memory::~Memory() {
    delete[] data;
}

void Memory::load_from_file(const std::string& file_path) {
    std::ifstream mem_file(file_path, std::ios::binary);
    if (mem_file.is_open()) {
        mem_file.read(reinterpret_cast<char*>(data), size);
        mem_file.close();
    }
}

void Memory::write(uint64_t addr, uint64_t value) {
    if (addr < size) {
        *reinterpret_cast<uint64_t*>(&data[addr]) = value;
    }
}

void Memory::read(uint64_t addr) {
    if (addr < size) {
        // +1 since usage is queue -> update -> get
        read_queue.emplace_back(latency + 1, addr);
    }
}

void Memory::update() {
    for (auto& [cycles, addr] : read_queue) {
        cycles--;
    }
}

std::optional<uint64_t> Memory::get_read_data() {
    if (!read_queue.empty() && read_queue.front().first == 0) {
        uint64_t addr = read_queue.front().second;
        read_queue.pop_front();
        return {*reinterpret_cast<uint64_t*>(&data[addr])};
    }
    return std::nullopt;
}

void Memory::compare_with_file(const std::string& file_path) {
    std::ifstream file(file_path);
    if (file.is_open()) {
        std::string line;
        uint64_t addr = 0;
        bool has_addr = false;
        std::vector<uint64_t> values;

        while (std::getline(file, line)) {
            if (line.empty()) {
                if (has_addr) {
                    compare_values(addr, values);
                    has_addr = false;
                    values.clear();
                }
            } else if (has_addr) {
                values.push_back(std::stoull(line.substr(2), nullptr, 16));
            } else if (line.substr(0, 2) == "0x") {
                addr = std::stoull(line.substr(2), nullptr, 16);
                has_addr = true;
            }
        }

        if (has_addr) {
            compare_values(addr, values);
        }

        file.close();
    } else {
        std::cout << "Unable to open file: " << file_path << std::endl;
    }
}

void Memory::compare_values(uint64_t addr, const std::vector<uint64_t>& values) {
    bool differences_found = false;

    for (size_t i = 0; i < values.size(); i++) {
        uint64_t mem_value = *reinterpret_cast<uint64_t*>(&data[addr + i * 8]);
        if (mem_value != values[i]) {
            if (!differences_found) {
                std::cout << "Differences found at addresses:" << std::endl;
                differences_found = true;
            }
            std::cout << "  0x" << std::hex << (addr + i * 8) << ": Expected 0x" << std::hex << values[i]
                      << ", Actual 0x" << std::hex << mem_value << std::endl;
        }
    }

    if (differences_found) {
        std::cout << std::endl;
    }
}