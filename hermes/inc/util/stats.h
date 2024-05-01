#ifndef STATS_H
#define STATS_H

#include "./features.h"

struct PredictStats {
    uint64_t called;
    uint64_t pred_true;
    uint64_t pred_false;
};

struct TrainStats {
    uint64_t called;
    uint64_t incr_weight_match;
    uint64_t incr_weight_mismatch;
    uint64_t decr_weight_match;
    uint64_t decr_weight_mismatch;
};

struct WeightAdjustmentStats {
    uint64_t incr_done[feature_type_t::num_feature_types];
    uint64_t incr_satu[feature_type_t::num_feature_types];
    uint64_t decr_done[feature_type_t::num_feature_types];
    uint64_t decr_satu[feature_type_t::num_feature_types];
};

struct Stats {
    PredictStats predict;
    TrainStats train;
    WeightAdjustmentStats weight;
};

#endif