# gets unigram distributions of words in a CoNLL-formatted file

import re, sys, time, nltk
from collections import defaultdict
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

start_time = time.time()

all_words = sys.argv[1] # conllwords.txt
vocab = sys.argv[2] # conllvocab.txt
text = sys.argv[3] # file containing prepositional phrases to be analyzed

fdict = {} # dictionary with word / word count pairs
lines = defaultdict( list )
output = []
i = 0
pp = 0 # counter for prepositional phrases contained in an utterance

# dictionary to contain word / word-frequency pairs for each prepositional phrase
phrases = {}


# generate frequency distribution based on all words in CHILDES corpus
all_words_reader = WordListCorpusReader( '.', all_words )
tok_words = all_words_reader.words() # grab word from each line of text
fdist = FreqDist( w for w in tok_words )

print("frequency distribution generated\n")

# calculate word frequencies based on vocabulary
vocab_reader = WordListCorpusReader( '.', vocab )
tok_vocab = vocab_reader.words() # grab word from each line of text

with open( 'child_same_len_unis.txt', 'w' ) as file1, open( text, 'r' ) as file2:
        for line in file2:
            lines[i] = line.split( '\t' ) # divide line into columns

            if( len( lines[i] ) > 1 ):
                lines[i].append( str( fdist.freq( lines[i][1] ) ) )

            output.append( lines[i] ) # buffer
            match = re.match( "-----", lines[i][0] )

            if( match ):
                for j in range(0, len( output ) ):
                    if( len( output[j] ) > 1 ):
                        for k in range( 0, len( output[j] ) ):
                            file1.write( output[j][k].rstrip( '\n' ) + '\t' )
                        file1.write( '\n' )

                    else:
                        file1.write( output[j][0] )

                output = []
            i = i + 1

print( "--- Execution time: %s minutes ---" % ( ( time.time() - start_time )/60 ) )
