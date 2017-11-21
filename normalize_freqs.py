import re, sys, nltk, pickle
from collections import defaultdict, OrderedDict
from nltk.probability import FreqDist
import numpy as np
import matplotlib.pyplot as plt

i = 0
ages_pps = []
ages_all = []
lines = defaultdict( list )

f1 = sys.argv[1] # adult or child 2PPs file
f2 = sys.argv[2] # all adult/child utterances

regex = re.compile('# child age:\t(\d+\;*\d*)(\.*\d*)')

# get number of 2 PPs with same head at each age
with open(f1, 'r') as fp1, open(f1 + '_fdist.txt', 'w+') as fp2:
    for line in fp1:
        lines[i] = line
        found = regex.search(line) # search for child age on line

        if(found):
            age = found.group(1) # if we found an age, store it in temp variable
            age = re.sub('((\;)(0*(?=\d)))', '.', age) # clean up instances like '8;04'
            age = re.sub('(\;(?!\d+))', '', age) # clean up instances like '8;'
            ages_pps.append(float(age))

        i = i + 1

    fdist_pps = FreqDist(a for a in ages_pps)

    for a in fdist_pps:
        print(str(a) + ': ' + str(fdist_pps[a]) +'\n')
        fp2.write(str(a) + '\t' + str(fdist_pps[a]) + '\n')

# get cumulative number of utterances per age to normalize data
with open(f2, 'r') as fp1, open(f2 + '_fdist.txt', 'w+') as fp2:
    for line in fp1:
        lines[i] = line
        found = regex.search(line) # search for child age on line

        if(found):
            age = found.group(1) # if we found an age, store it in temp variable
            age = re.sub('((\;)(0*(?=\d)))', '.', age) # clean up instances like '8;04'
            age = re.sub('(\;(?!\d+))', '', age) # clean up instances like '8;'
            ages_all.append(float(age))

        i = i + 1

    fdist_all = FreqDist(a for a in ages_all)

    for a in fdist_all:
        print(str(a) + ': ' + str(fdist_all[a]) +'\n')
        fp2.write(str(a) + '\t' + str(fdist_all[a]) + '\n')

# normalize frequencies before plotting
for a in fdist_pps:
    fdist_pps[a] = fdist_pps[a] / fdist_all[a]

ordered_pps = OrderedDict(sorted(fdist_pps.items(), key=lambda t: t[0]))

last = 0

for a in ordered_pps:
	ordered_pps[a] = ordered_pps[a] + last
	last = ordered_pps[a]
	print(str(a) + '\t' + str(ordered_pps[a]))
	
# dump data into files
pickle.dump(ordered_pps, open(f1 + ".dict", "wb"))
pickle.dump(ages_pps, open(f1 + ".ages", "wb"))



