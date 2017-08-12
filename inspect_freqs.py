# calculate average word frequencies of two prepositional phrases
# based on the difference in length between each phrase

import re, sys, time, nltk
from nltk.probability import FreqDist
from collections import defaultdict

infile = sys.argv[1] # file containing CoNLL-formatted text with word frequencies appended

pp_count = 0 # counter to keep track of prepositional phrases contained in utterance

# dictionary to contain lines of infile
lines = defaultdict( list )
i = 0

# dictionary to contain word / word-freq pairs for prepositional phrases in utterance
phrases = defaultdict( dict ) 

with open( infile, 'r' ) as file1, open( "pp_word_freqs.txt", 'a+' ) as file2:

    # get all lines of infile
    for line in file1:
        lines[i] = line.split( '\t' ) # divide line into columns
        i = i + 1
        
    # iterate over each line of file
    for j in range(0, len( lines ) ):
        match = re.match( "-----", lines[j][0] )
        sentence = re.match( "# text", lines[j][0] )

        # while not at end of utterance
        if( sentence ):
            file2.write( lines[j][0] + '\n' )
            
        if( not match ):
            if( len(lines[j]) > 1 ):

                # if current word is a prep
                if( lines[j][3] == 'prep' ):
                    pp_count = pp_count + 1

                    # if prep immediately preceded by adv
                    if( len( lines[j - 1] ) > 1 and lines[j - 1][3] == 'adv' ):
                        phrases[pp_count][lines[j - 1][1]] = lines[j - 1][8]
                        file2.write( lines[j - 1][1] + ": " + phrases[pp_count][lines[j - 1][1]] + '\n' )
                    
                    # add word frequencies of each word in pp
                    for k in range( j, len( lines ) ):
                        if( lines[k][7] != 'POBJ' ):
                            phrases[pp_count][lines[k][1]] = lines[k][8]
                            file2.write( lines[k][1] + ":\t" + phrases[pp_count][lines[k][1]] + '\n' )
                     
                        if( lines[k][7] == 'POBJ' ):
                            phrases[pp_count][lines[k][1]] = lines[k][8]
                            file2.write( lines[k][1] + ":\t" + phrases[pp_count][lines[k][1]] + '\n\n' )
                            break # end of pp

            else:
                pp_count = 0 # reset for next utterance
                continue
        
    
        
    