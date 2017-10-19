import re, sys, nltk
from nltk.probability import FreqDist
import numpy as np
import matplotlib.pyplot as plt

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