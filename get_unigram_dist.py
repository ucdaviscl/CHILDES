# gets unigram distributions of words CoNLL-formatted file

import re, sys, time, nltk
from collections import defaultdict
from nltk.probability import FreqDist
from nltk.corpus.reader import WordListCorpusReader

start_time = time.time()

all_words = sys.argv[1] # conllwords.txt
vocab = sys.argv[2] # conllfdistwords.txt
text = sys.argv[3] # file containing prepositional phrases to be analyzed (output.txt)

fdict = {} # dictionary with word / word count pairs
lines = defaultdict( list )
output = []
i = 0
p = 0

# generate frequency distribution based on all words in CHILDES corpus
all_words_reader = WordListCorpusReader( '.', all_words )
tok_words = all_words_reader.words() # grab word from each line of text
fdist = FreqDist( w.lower() for w in tok_words ) 

# calculate word frequencies based on vocabulary
vocab_reader = WordListCorpusReader( '.', vocab )
tok_vocab = vocab_reader.words() # grab word from each line of text

for w in tok_vocab:
    fdict[w] = fdist.freq(w) # get frequency of each word in vocabulary
    
with open( 'long2short_unigrams.txt', 'w' ) as file1, open( text, 'r' ) as file2:
        for line in file2:
            lines[i] = line.split( '\t' ) # divide line into columns
            
            if(len( lines[i]) > 1 ):
                lines[i].append( str( fdist.freq( lines[i][1].lower() ) ) )
            
            output.append(lines[i]) # buffer    
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
            
print("--- Execution time: %s minutes ---" % ((time.time() - start_time)/60))
