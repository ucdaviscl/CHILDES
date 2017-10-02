#!/usr/bin/perl

# converts .cha Japanese files to CONLL format
# TODO clean up column entries

use strict;
use File::Find::Rule;

my $dirname = shift;

# get all files of .cha extension
my @flist = File::Find::Rule->file()
->name( '*.cha' )
->in( $dirname );

foreach my $fname ( @flist ) {
    
    open FP, $fname or die "Cannot open $fname\n";
    
    my $str = "";
    
    while( <FP> ) {
        chomp;
        $str .= $_;
    }
    
    $str =~ s/\t/ /g;
    
    $str =~ s/([\*\%])/\n$1/g;
    
    my @lines = split "\n", $str;
    
    my @trn = (); # similar format to %mor
    my @grt = (); # same format as %gra
    
    for( my $i = 0; $i < @lines; $i++ ) {
        
        if( $lines[$i] =~ /\*/ ) {
            print "# file name: $fname\n";
            print "# line number: $i\n";
            print "# text = $lines[$i]\n";
        
            if( $lines[$i + 1] !~ /^\%trn:/ ) {
                print "\n-----\n\n";
            }
        }
        
        if( $lines[$i] =~ /^\%trn:/ ) {
            @trn = split '[ ~]', $lines[$i];
        }
        
        if( $lines[$i] =~ /^\%grt:/ ) {
            @grt = split '[ ~]', $lines[$i];
            
            shift @trn;
            shift @grt;
        
            my $ngrt = @grt;
            my $ntrn = @trn;
            
            if( $ngrt != $ntrn ) {
                print "Line $i: Length mismatch $ngrt $ntrn\n";
            }
            
            for( my $j = 0; $j < $ntrn; $j++ ) {
                my $word = $trn[$j];
                my $lemma = $trn[$j];
                my $pos = "punct";
                my $morph = "_";
                
                if( $trn[$j] =~ /(.+)\|(.+)/ ) {
                    $word = $2;
                    $lemma = $2;
                    $pos = $1;
                    
                    if( $word =~ /([^\&\-]+)([\&\-].+)/ ) {
                        $lemma = $1;
                        $morph = $2;
                    }
                }
                
                my $idx = 0;
                my $headidx = 0;
                my $gr = "NONE";
                
                if( $grt[$j] =~ /(.+)\|(.+)\|(.+)/ ) {
                    $idx = $1;
                    $headidx = $2;
                    $gr = $3;
                }
                
                print "$idx\t$word\t$lemma\t$pos\t$pos\t$morph\t$headidx\t$gr\n";
                
            }
            print "\n-----\n\n";
            
        }
        
        if( /^\*/ ) {
            @trn = ();
            @grt = ();
        }
        
    }
}
