import re, sys, nltk
from collections import defaultdict
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

i = 0
ages = []
lines = defaultdict( list )

infile = sys.argv[1]

regex = re.compile('# child age:\t(\d+\;*\d*)(\.*\d*)')

# write ages from infile to intermediate file
# intermediate file will have one age per line
with open(infile, 'r') as fp1, open(infile + '_fdist.txt', 'w+') as fp2:
    for line in fp1:
        lines[i] = line
        found = regex.search(line) # search for child age on line
         
        if(found):
            age = found.group(1) # if we found an age, store it in temp variable
            age = re.sub('((\;)(0*(?=\d)))', '.', age) # clean up instances like '8;04'
            age = re.sub('(\;(?!\d+))', '', age) # clean up instances like '8;'
            ages.append(float(age))
            
        i = i + 1
        
    fdist = FreqDist(a for a in ages)
   
    for a in fdist:
        print(str(a) + ': ' + str(fdist[a]) +'\n')
        fp2.write(str(a) + '\t' + str(fdist[a]) + '\n')