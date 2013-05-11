#!/bin/bash

n_tmpl=800
n_bin=4
profile=61c

cd svm-multiclass
./svm_multiclass_learn -c 100000 ../data/fbank-$profile-train-$n_tmpl-$n_bin.svmlight fbank-vec-$n_tmpl-$n_bin.model
./svm_multiclass_classify ../data/fbank-$profile-dev-$n_tmpl-$n_bin.svmlight fbank-$profile-$n_tmpl-$n_bin.model fbank-$profile-dev-$n_tmpl-$n_bin.prediction

