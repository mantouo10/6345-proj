#!/usr/bin/python
# generate index for each speaker
with open('data/train_data_order.txt') as ins:
    mapping = dict()
    idx = 0
    for line in ins:
        speaker = line.strip().split('-')[2]
        idx += 1
        if speaker in mapping:
            mapping[speaker].append(idx)
        else:
            mapping[speaker] = [idx]

import numpy

index = numpy.zeros((len(mapping), idx))
spk_index = list(mapping.itervalues())
for i in range(len(spk_index)):
    for j in spk_index[i]:
        index[i,j-1] = 1

import scipy.io
scipy.io.savemat('speaker_index.mat', {'index': index})
