# TODO group ages in 6-month intervals
# TODO normalize frequencies 

import re, sys, nltk
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

i = 0
ages = []
lines = defaultdict( list )
infile = sys.argv[1] # file containing PPs/ child ages to plot


regex = re.compile('# child age:\t(\d+\;*\d*)(\.*\d*)')

# write ages from infile to intermediate file
# intermediate file will have one age per line
with open(infile, 'r') as file1, open('ages.txt', 'w+') as file2:
    for line in file1:
        lines[i] = line
        found = regex.search(line) # search for child age on line
         
        if(found):
            age = found.group(1) # if we found an age, store it in temp variable
            age = re.sub('((\;)(0*(?=\d)))', '.', age) # clean up instances like '8;04'
            age = re.sub('(\;(?!\d+))', '', age) # clean up instances like '8;'
            ages.append(float(age))
            
        i = i + 1
        
    fdist = FreqDist(a for a in ages)

# plot data using matplotlib
# y axis: total number of 2PP occurrences
# x axis: child age

x = [a for a in ages]
y = [fdist[a] for a in ages]

fig = plt.figure()

axes = fig.add_subplot(111)

axes.set_title('Child age vs. Instances of 2 PPs with Same Head')    
axes.set_xlabel('Child Ages')
axes.set_ylabel('Total # of Instances of 2 PPs with Same Head')

plt.xticks(np.arange(1, 13, 0.5))

axes.plot(x, y,'md', label='Age Group')

leg = axes.legend()

plt.show()