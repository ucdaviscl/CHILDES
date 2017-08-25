#!/usr/bin/perl

use strict;
use File::Find;

my $dirname = shift;

my @flist = <$dirname/*.txt>;

my $outfile = "morph_counts.txt";
        
open my $fh, '>', $outfile or die "Cannot open $outfile\n";

foreach my $fname ( @flist ) {
    open FP, $fname or die "Cannot open $fname\n";

    my $str = "";

    while( <FP> ) {
        $str .= $_;
    } 
    
    my @lines = split "\n", $str;
    
    my $morph_count = 0;
    my $difference = 0;
    
    my @morphs = (); # holds a word split on morpheme delimiters
    my @pp_morph_counts = (); # holds morpheme counts of each prepositional phrase
    my %cols = (); # hash of arrays

    my $long2short_count = 0; # len1 - len2 > 0
    my $short2long_count = 0; # len1 - len2 < 0
    my $same_len_count = 0;     # len1 - len2 == 0
            
    my $idx = 0;
    my $temp; # holds word split on morpheme delimiters 
    
    # divide CoNLL formatted text into columns
    for( my $k = 0; $k < @lines; $k++ ) {
        @{$cols{$k}} = split "\t", $lines[$k]; 
    } 
    
    for( my $i = 0; $i < @lines; $i++ ) {
         if( $cols{$i}->[3] =~ /prep/ ) {
                $temp = $cols{$i}->[1];
                @morphs = split "/\&|\-/", $temp; # split word into morphemes
                $morph_count++;
                
                # determine which "morphemes" are valid
                foreach my $chars ( @morphs ) {
                        
                        # if word segment contains no lowercase letters, increment $morph_count
                        if( $chars !~ /[a-z]+/ ) {
                                $morph_count++;
                        }
                }
                
                @morphs = ();

                # if immediately preceded by adv with same head as prep, push adv index
                if( $cols{$i - 1}->[3] =~ /adv/ && $cols{$i - 1}->[6] == $cols{$i}->[6] ) {
                        $temp = $cols{$i}->[1];
                        @morphs = split "/\&|\-/", $temp; # split word into morphemes
                        $morph_count++;
                        
                        # determine which "morphemes" are valid
                        foreach my $chars ( @morphs ) {
                        
                                # if word segment contains no lowercase letters, increment $morph_count
                                if( $chars !~ /[a-z]+/ ) {
                                        $morph_count++;
                                }
                        }
                        
                        @morphs = ();
                }

                for( my $j = $i + 1; $j < @lines; $j++ ) {
                
                        # last word in prepositional phrase
                        if( $cols{$j}->[7] =~ /POBJ/ ) {
                                $temp = $cols{$i}->[1];
                                @morphs = split "/\&|\-/", $temp; # split word into morphemes
                                $morph_count++;
                                
                                # determine which "morphemes" are valid
                                foreach my $chars ( @morphs ) {
                
                                        # if word segment contains no lowercase letters, increment $morph_count
                                        if( $chars !~ /[a-z]+/ ) {
                                                $morph_count++;
                                        }                
                                }
                                
                                # push total morph count of prepositional phrase
                                push @pp_morph_counts, $morph_count;
                                $morph_count = 0; # reset for next prepositional phrase
                                @morphs = ();
                                
                                last; # break
                        } 
                        
                        else {
                                $temp = $cols{$i}->[1];
                                @morphs = split "/\&|\-/", $temp; # split word into morphemes
                                $morph_count++;
                                
                                # determine which "morphemes" are valid
                                foreach my $chars ( @morphs ) {
                
                                        # if word segment contains no lowercase letters, increment $morph_count
                                        if( $chars !~ /[a-z]+/ ) {
                                                $morph_count++;
                                        }                
                                }
                                
                                @morphs = ();
                        }
                }
         }
        
        if( $lines[$i] =~ /\-\-\-\-\-/ ) {
                $difference = $pp_morph_counts[0] - $pp_morph_counts[1];
                $idx++;

                if( $difference > 0 ) {
                        print $fh "long2short count + 1\n";
                        $long2short_count++;
                } 
                
                if( $difference == 0 ) {
                        print $fh "same len count + 1\n";
                        $same_len_count++;
                } 
                
                if( $difference < 0 ) {
                        print $fh "short2long count + 1\n";
                        $short2long_count++;
                }

                print $fh "short2long: $short2long_count\n";
                print $fh "long2short: $long2short_count\n";
                print $fh "samelen: $same_len_count\n";

                # clear array for next utterance
                @pp_morph_counts = (); 

                print $fh "\n-----\n";
                
                next;
        }
        
        print $fh "$lines[$i]\n";
    } 
}