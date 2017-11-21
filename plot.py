import sys, pickle
from collections import defaultdict, OrderedDict
import numpy as np
import matplotlib.pyplot as plt

# plot data using matplotlib
# y axis: total number of 2PP occurrences
# x axis: child age

adult_dict = sys.argv[1]
child_dict = sys.argv[2]
child_ages_adult = sys.argv[3]
child_ages_child = sys.argv[4]

adult_dict_nv = sys.argv[5]
child_dict_nv = sys.argv[6]
child_ages_adult_nv = sys.argv[7]
child_ages_child_nv = sys.argv[8]

adult_data = pickle.load(open(sys.argv[1], "rb"))
child_data = pickle.load(open(sys.argv[2], "rb"))
ages_adult = pickle.load(open(sys.argv[3], "rb"))
ages_child = pickle.load(open(sys.argv[4], "rb"))

adult_nv = pickle.load(open(sys.argv[5], "rb"))
child_nv = pickle.load(open(sys.argv[6], "rb"))
ages_adult_nv = pickle.load(open(sys.argv[7], "rb"))
ages_child_nv = pickle.load(open(sys.argv[8], "rb"))

x1 = np.array([a for a in ages_child])
x2 = np.array([a for a in ages_adult])
x3 = np.array([a for a in ages_child_nv])
x4 = np.array([a for a in ages_adult_nv])

y1 = np.array([child_data[a] for a in ages_child])
y2 = np.array([adult_data[a] for a in ages_adult])
y3 = np.array([child_nv[a] for a in ages_child_nv])
y4 = np.array([adult_nv[a] for a in ages_adult_nv])

fig = plt.figure()

axes = fig.add_subplot(111)

axes.set_title('Child Age vs. Instances of 2 PPs with Same Head')
axes.set_xlabel('Child Ages')
axes.set_ylabel('# of Instances of 2 PPs with Same Head (Normalized by Age)')

plt.xticks(np.arange(0, 19.5, 0.5))
plt.xticks(rotation=45)

axes.plot(x4, y4,'m.', label='Parent (Non-Violating)')
axes.plot(x3, y3,'b.', label='Child (Non-Violating)')
axes.plot(x2, y2,'r.', label='Parent (All)')
axes.plot(x1, y1,'g.', label='Child (All)')

leg = axes.legend()

plt.show()