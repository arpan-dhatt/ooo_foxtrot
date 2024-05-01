#include "../inc/hermes.h"
#include "../inc/util/features.h"
#include <iostream>

void perceptron_pred_t::incr_weights(vector<uint32_t> weight_indices) {
    for(uint32_t feature = 0; feature < num_features; ++feature) {
        uint32_t index = weight_indices[feature];
        float& current_weight = weights[feature].array[index];
        const string& feature_name = feature_names[activated_features[feature]];
        float new_weight = current_weight + pos_weight_delta;

        if(new_weight <= max_weight) {
            std::cout << "feature " << feature_name << " index " << index << " old_weight " << current_weight << std::endl;
            current_weight = new_weight;
            std::cout << "feature " << feature_name << " index " << index << " new_weight " << current_weight << std::endl;
            stats.weight.incr_done[activated_features[feature]]++;
        } else {
            std::cout << "feature " << feature_name << " index " << index << " saturated_weight " << current_weight << std::endl;
            stats.weight.incr_satu[activated_features[feature]]++;
        }
    }
}

void perceptron_pred_t::decr_weights(vector<uint32_t> weight_indices) {
    for(uint32_t feature = 0; feature < num_features; ++feature) {
        uint32_t index = weight_indices[feature];
        float& current_weight = weights[feature].array[index];
        const string& feature_name = feature_names[activated_features[feature]];
        float new_weight = current_weight - neg_weight_delta;

        if(new_weight >= min_weight) {
            std::cout << "feature " << feature_name << " index " << index << " old_weight " << current_weight << std::endl;
            current_weight = new_weight;
            std::cout << "feature " << feature_name << " index " << index << " new_weight " << current_weight << std::endl;
            stats.weight.decr_done[activated_features[feature]]++;
        } else {
            std::cout << "feature " << feature_name << " index " << index << " saturated_weight " << current_weight << std::endl;
            stats.weight.decr_satu[activated_features[feature]]++;
        }
    }
}

vector<uint32_t> perceptron_pred_t::generate_indices_from_state(state_info_t *state) {
    vector<uint32_t> indices;
    for(uint32_t index = 0; index < num_features; ++index) {
        indices.push_back(generate_index_from_feature((feature_type_t)activated_features[index], state, 0xdeadbeef, feature_hash_types[index], weights[index].size));
    }
    return indices;
}
