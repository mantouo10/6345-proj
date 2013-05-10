#!/bin/bash

n_tmpl=800
n_bin=4

cd svm-multiclass
./svm_multiclass_learn -c 1 ../data/fbank-vec-train-$n_tmpl-$n_bin.svmlight fbank-vec-$n_tmpl-$n_bin.model
./svm_multiclass_classify ../data/fbank-vec-dev-$n_tmpl-$n_bin.svmlight fbank-vec-$n_tmpl-$n_bin.model fbank-vec-dev-$n_tmpl-$n_bin.prediction

