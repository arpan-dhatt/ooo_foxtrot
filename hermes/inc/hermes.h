#ifndef PERCEPTRON_PREDICTOR_H
#define PERCEPTRON_PREDICTOR_H

#include <vector>
#include <stdint.h>
#include <string>
#include <iostream>
#include "./util/weight_array.h"
#include "./util/state_info.h"
#include "./util/features.h"
#include "./util/stats.h"

using namespace std;

class perceptron_pred_t {
public:
    float activation_threshold;
    float max_weight;
    float min_weight;
    float pos_weight_delta;
    float neg_weight_delta;
    float pos_train_thresh;
    float neg_train_thresh;
    uint32_t num_features;
    vector<int32_t> activated_features;
    vector<weight_array_t> weights;
    vector<int32_t> feature_hash_types;
    Stats stats;

    perceptron_pred_t(vector<int32_t> _activated_features, vector<int32_t> weight_array_sizes, vector<int32_t> feature_hash_types, float threshold, float max_w, float min_w, float pos_delta, float neg_delta, float pos_thresh, float neg_thresh);
    ~perceptron_pred_t() {}

    void incr_weights(vector<uint32_t> weight_indices);
    void decr_weights(vector<uint32_t> weight_indices);
    vector<uint32_t> generate_indices_from_state(state_info_t *state);

    uint32_t generate_index_from_feature(feature_type_t feature, state_info_t *info, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size);
    
    void predict(state_info_t *state, bool &prediction, float &perc_weight_sum);
    void train(state_info_t *state, float perc_weight_sum, bool pred_output, bool true_output);

    void dump_stats();
    void reset_stats();

    void log_train_event(state_info_t *state, float perc_weight_sum, bool true_output, bool pred_output) {
        std::cout << "==========================" << std::endl;
        std::cout << "Training event: " << state->to_string() << " - Weight Sum: " << perc_weight_sum << ", Actual: " << true_output << ", Predicted: " << pred_output << std::endl;
        std::cout << "==========================" << std::endl;
    }

    void process_correct_prediction(float perc_weight_sum, vector<uint32_t>& weight_indices) {
        if (perc_weight_sum >= neg_train_thresh && perc_weight_sum <= pos_train_thresh) {
            std::cout << "Correct prediction: Adjusting weights upwards..." << std::endl;
            perceptron_pred_t::incr_weights(weight_indices);
            stats.train.incr_weight_match++;
        } else {
            std::cout << "Correct prediction: Weights are already saturated..." << std::endl;
        }
    }

    void process_incorrect_prediction(float perc_weight_sum, vector<uint32_t>& weight_indices) {
        if (perc_weight_sum >= neg_train_thresh && perc_weight_sum <= pos_train_thresh) {
            std::cout << "Incorrect prediction: Adjusting weights downwards..." << std::endl;
            perceptron_pred_t::decr_weights(weight_indices);
            stats.train.decr_weight_match++;
        } else {
            std::cout << "Incorrect prediction: Weights are already saturated..." << std::endl;
        }
    }
};

#endif /* PERCEPTRON_PREDICTOR_H */