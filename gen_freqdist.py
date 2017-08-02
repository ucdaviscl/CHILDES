# generates a frequency distribution of the words in the Eng-NA CHILDES corpus

import nltk
from nltk.probability import FreqDist
from nltk.corpus.reader import CHILDESCorpusReader

corpus_root = nltk.data.find('corpora/childes/data_xml/Eng-NA/')
childes_files = CHILDESCorpusReader(corpus_root, '.*/.*.xml')

# get tokenized representation of all words in files
allwords = childes_files.words(childes_files.fileids())

# generate a frequency distribution
fdist = FreqDist(w.lower() for w in allwords)

# output frequency distribution to file
with open('fdist.txt', 'w') as fp:
	for f in fdist:
		print(f, '\t', fdist[f])
		fp.write('%s \t %d\n' % (f, fdist[f]))

								
	

