# generates a frequency distribution of words contained in a text file
# input file is in CoNLL format

import sys
import nltk
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

words = []
infile = sys.argv[1]

# write words from infile to intermediate file
# intermediate file will have one word per line
with open(infile, 'r') as file1, open('conllwords.txt', 'w+') as file2:
	for line in file1:
		if(line):
			line = line.split('\t') # divide CoNLL-formatted file into columns
			if(len(line) > 1):
				file2.write('{}\n'.format(line[1])) # get second column of CoNLL file
	
reader = WordListCorpusReader('.', 'conllwords.txt')

words = reader.words() # grab word from each line of text
fdist = FreqDist(w.lower() for w in words) # generate frequency distribution

# output frequency distribution to file
with open('conllfdist.txt', 'w') as outfile:
	for f in fdist:
		outfile.write('%s \t %d\n' % (f, fdist[f]))