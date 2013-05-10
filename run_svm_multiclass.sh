#!/bin/bash

cd svm-multiclass
./svm_multiclass_learn -c 1 ../data/fbank-vec-train.svmlight fbank-vec.model
./svm_multiclass_classify ../data/fbank-vec-dev.svmlight fbank-vec.model fbank-vec-dev.prediction

