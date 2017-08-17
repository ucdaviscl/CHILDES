# calculate average word frequencies of two prepositional phrases
# based on the difference in length between each phrase

import re, sys, time, nltk
from nltk.probability import FreqDist
from collections import defaultdict

infile = sys.argv[1] # file containing CoNLL-formatted text with word frequencies appended

# dictionary to contain lines of infile
lines = defaultdict( list )
phrase_probs = []

phrase_prob = 1 # unigram probability of prepositional phrase
pp_count = 0 # counter to keep track of prepositional phrases contained in utterance
i = 0

# dictionary to contain word / word-freq pairs for prepositional phrases in utterance
phrases = defaultdict( dict )

with open( infile, 'r' ) as file1, open( 'same_len_pp_word_freqs.txt', 'a+' ) as file2:

    # get all lines of infile
    for line in file1:
        lines[i] = line.split( '\t' ) # divide line into columns
        i = i + 1

    # iterate over each line of file
    for j in range(0, len( lines ) ):
        match = re.match( '-----', lines[j][0] )
        sentence = re.match( '# text', lines[j][0] )

        # while not at end of utterance
        if( sentence ):
            file2.write( lines[j][0] + '\n' )

        if( not match ):
            if( len(lines[j]) > 1 ):

                # if current word is a prep
                if( lines[j][3] == 'prep' ):
                    pp_count = pp_count + 1
                    phrase_prob = 1

                    # if immediately preceded by adv with same head as prep
                    if( len( lines[j - 1] ) > 1 and ( re.match( 'adv', lines[j - 1][3] ) and lines[j - 1][6] == lines[j][6] ) ):
                        phrases[pp_count][lines[j - 1][1]] = lines[j - 1][8]
                        phrase_prob = phrase_prob * float(lines[j - 1][8])
                        file2.write( lines[j - 1][1] + ':\t' + phrases[pp_count][lines[j - 1][1]] + '\n' )

                    # add word frequencies of each word in pp
                    for k in range( j, len( lines ) ):
                        if( lines[k][7] != 'POBJ' ):
                            phrases[pp_count][lines[k][1]] = lines[k][8]
                            phrase_prob = phrase_prob * float(lines[k][8])
                            file2.write( lines[k][1] + ':\t' + phrases[pp_count][lines[k][1]] + '\n' )

                        if( lines[k][7] == 'POBJ' ):
                            phrases[pp_count][lines[k][1]] = lines[k][8]
                            phrase_prob = phrase_prob * float(lines[k][8])
                            phrase_probs.append(phrase_prob)
                            file2.write( lines[k][1] + ':\t' + phrases[pp_count][lines[k][1]] + '\n\n' )
                            file2.write( 'phrase unigram probability:\t' + str(phrase_prob) + '\n\n' )
                            break # end of pp

        else:
            if( phrase_probs[0] > phrase_probs[1] ):
                file2.write( 'pp1 is more probable than pp2 by:\t' + str(phrase_probs[0] - phrase_probs[1]) + '\n\n' )

            elif( phrase_probs[0] < phrase_probs[1] ):
                file2.write( 'pp2 is more probable than pp1 by:\t' + str(phrase_probs[1] - phrase_probs[0]) + '\n\n' )

            else:
                file2.write( 'pp1 and pp2 are equally probable \n\n' )

            pp_count = 0 # reset for next utterance
            phrase_probs = []
            continue
