# gets unigram distributions of words CoNLL-formatted file

import re, sys, nltk
from collections import defaultdict
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

words = sys.argv[1] # conllwords.txt
text = sys.argv[2] # file containing prepositional phrases to be analyzed (output.txt)

fdict = {} # dictionary with word / word count pairs
lines = defaultdict(list)
output = []
i = 0

reader = WordListCorpusReader('.', words)
words = reader.words() # grab word from each line of text
fdist = FreqDist(w.lower() for w in words) # generate frequency distribution

for w in words:
	fdict[w] = fdist.freq(w) # get frequency of each word in vocabulary
	
with open('long2short_unigrams.txt', 'w') as file1, open(text, 'r') as file2:
		for line in file2:
			lines[i] = line.split('\t') # divide line into columns
			
			if(len(lines[i]) > 1):
				lines[i].append(fdist.freq(lines[i][1].lower()))
			
			output.append(lines[i]) # buffer	
			match = re.match("-----", lines[i][0])
			
			if(match):
				for element in output:
					print(element)
				output = []
				print('\n')
				
			i = i + 1
