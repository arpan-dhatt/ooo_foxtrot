#include "./inc/hermes_test.h"
#include <iostream>

int main() {
    PerceptronPredTest test;

    try {
        std::cout << "Testing constructor..." << std::endl;
        test.TestConstructor();

        std::cout << "Testing predict function..." << std::endl;
        test.TestPredict();

        std::cout << "Testing train function..." << std::endl;
        test.TestTrain();
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}