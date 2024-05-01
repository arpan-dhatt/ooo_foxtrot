#include <iostream>
#include <iomanip>
#include <assert.h>
#include "./inc/hermes.h"

using namespace std;

void perceptron_pred_t::predict(state_info_t *state, bool &prediction, float &perc_weight_sum) {
    stats.predict.called++;
    vector<uint32_t> weight_indices = generate_indices_from_state(state);
    assert(weight_indices.size() == num_features);

    float cumulative_weight = 0.0;
    for (uint32_t feature = 0; feature < num_features; ++feature) {
        assert(weight_indices[feature] < weights[feature].size);
        cumulative_weight += weights[feature].array[weight_indices[feature]]; // sum up all feature weights
    }
    perc_weight_sum = cumulative_weight;
    prediction = (cumulative_weight >= activation_threshold) ? true : false;

    if (prediction)
        stats.predict.pred_true++;
    else
        stats.predict.pred_false++;
}

void perceptron_pred_t::train(state_info_t *state, float perc_weight_sum, bool pred_output, bool true_output) {
    stats.train.called++;
    log_train_event(state, perc_weight_sum, true_output, pred_output);
    vector<uint32_t> weight_indices = generate_indices_from_state(state);
    assert(weight_indices.size() == num_features);

    if (true_output) {
        if (pred_output == true_output) {
            process_correct_prediction(perc_weight_sum, weight_indices);
        } else {
            std::cout << "Incorrect prediction: Real=true, Predicted=false. Increasing weights..." << std::endl;
            incr_weights(weight_indices);
            stats.train.incr_weight_mismatch++;
        }
    } else {
        if (pred_output == true_output) {
            process_incorrect_prediction(perc_weight_sum, weight_indices);
        } else {
            std::cout << "Incorrect prediction: Real=false, Predicted=true. Decreasing weights..." << std::endl;
            decr_weights(weight_indices);
            stats.train.decr_weight_mismatch++;
        }
    }
}