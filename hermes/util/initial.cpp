#include <iostream>
#include <iomanip>
#include <assert.h>
#include "../inc/hermes.h"

perceptron_pred_t::perceptron_pred_t(vector<int32_t> _activated_features, vector<int32_t> weight_array_sizes, vector<int32_t> hash_types, float threshold, float max_w, float min_w, float pos_delta, float neg_delta, float pos_thresh, float neg_thresh)
    : activation_threshold(threshold),
      max_weight(max_w),
      min_weight(min_w),
      pos_weight_delta(pos_delta),
      neg_weight_delta(neg_delta),
      pos_train_thresh(pos_thresh),
      neg_train_thresh(neg_thresh)
{
    assert(_activated_features.size() == weight_array_sizes.size());
    assert(_activated_features.size() == hash_types.size());

    num_features = _activated_features.size();
    activated_features = _activated_features;
    for(uint32_t index = 0; index < weight_array_sizes.size(); ++index)
    {
        weights.push_back(weight_array_t(weight_array_sizes[index]));
    }
    feature_hash_types = hash_types;
}