#ifndef PERCEPTRON_PRED_TEST_H
#define PERCEPTRON_PRED_TEST_H

#include <vector>
#include <cstdint>
#include "./hermes.h"

class PerceptronPredTest {
public:
    std::vector<int32_t> activated_features{0, 1, 2};
    std::vector<int32_t> array_sizes{10, 10, 10};
    std::vector<int32_t> feature_hash_types{1, 1, 1};
    float activation_threshold = 0.5f;
    float max_weight = 10.0f;
    float min_weight = -10.0f;
    float pos_weight_delta = 0.1f;
    float neg_weight_delta = 0.1f;
    float pos_train_thresh = 0.8f;
    float neg_train_thresh = 0.2f;
    perceptron_pred_t *perceptron;

    PerceptronPredTest() : perceptron(new perceptron_pred_t(
        activated_features, 
        array_sizes, 
        feature_hash_types, 
        activation_threshold,
        max_weight,
        min_weight,
        pos_weight_delta,
        neg_weight_delta,
        pos_train_thresh,
        neg_train_thresh
    )) {}

    ~PerceptronPredTest() {
        delete perceptron;
    }

    void TestConstructor() {
        if (perceptron == nullptr) {
            throw std::runtime_error("Perceptron predictor instance should not be null");
        }
    }

    void TestPredict() {
        state_info_t state;
        bool prediction;
        float perc_weight_sum;

        perceptron->predict(&state, prediction, perc_weight_sum);
    }

    void TestTrain() {
        state_info_t state;
        float perc_weight_sum = 0.5f;
        bool pred_output = true;
        bool true_output = true;

        perceptron->train(&state, perc_weight_sum, pred_output, true_output);
    }
};

#endif