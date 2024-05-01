#include "../inc/hermes.h"
#include "../inc/util/features.h"
#include <iostream>
#include <strings.h>

std::string feature_names[num_feature_types] = {
    "PC",
    "Offset",
    "Page",
    "Addr",
    "FirstAccess",
    "PC_Offset",
    "PC_Page",
    "PC_Addr",
    "PC_FirstAccess",
    "Offset_FirstAccess",
    "CLOffset",
    "PC_CLOffset",
    "CLWordOffset",
    "PC_CLWordOffset",
    "CLDWordOffset",
    "PC_CLDWordOffset",
    "LastNLoadPCs",
    "LastNPCs"
};

void perceptron_pred_t::dump_stats()
{
    cout << "perc_predict_called " << stats.predict.called << endl
         << "perc_predict_pred_true " << stats.predict.pred_true << endl
         << "perc_predict_pred_false " << stats.predict.pred_false << endl
         << "perc_train_called " << stats.train.called << endl
         << "perc_train_incr_weight_match " << stats.train.incr_weight_match << endl
         << "perc_train_incr_weight_mismatch " << stats.train.incr_weight_mismatch << endl
         << "perc_train_decr_weight_match " << stats.train.decr_weight_match << endl
         << "perc_train_decr_weight_mismatch " << stats.train.decr_weight_mismatch << endl
         << endl;

    for(uint32_t feature = 0; feature < num_features; ++feature)
    {
        cout << "perc_feature_" << feature_names[activated_features[feature]] << "_incr_done " << stats.weight.incr_done[activated_features[feature]] << endl
             << "perc_feature_" << feature_names[activated_features[feature]] << "_incr_satu " << stats.weight.incr_satu[activated_features[feature]] << endl
             << "perc_feature_" << feature_names[activated_features[feature]] << "_decr_done " << stats.weight.decr_done[activated_features[feature]] << endl
             << "perc_feature_" << feature_names[activated_features[feature]] << "_decr_satu " << stats.weight.decr_satu[activated_features[feature]] << endl
             << endl;
    }
}

void perceptron_pred_t::reset_stats()
{
    bzero(&stats, sizeof(stats));
}