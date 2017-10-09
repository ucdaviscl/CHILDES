#!/usr/bin/perl

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
    my $age = "";
    my $header = "";
    
    while( <FP> ) {
        chomp;
        $str .= $_;
        $header .= $_;
    }
    
    # grab CHI info up to and including age
    
    if( $header =~ /([a-zA-Z]+)\|([a-zA-Z]+)\|(CHI)\|(\d+;*\d*\.*\d*)\|/ ) {
        $age = $4;
    }

    $str =~ s/\t/ /g;

    $str =~ s/([\*\%])/\n$1/g;

    my @lines = split "\n", $str;

    my @mor = ();
    my @gra = ();

    for( my $i = 0; $i < @lines; $i++ ) {

        if( $lines[$i] =~ /\*/ ) {
            print "# file name: $fname\n";
            print "# child age:\t$age\n";
            print "# line number: $i\n";
            print "# text = $lines[$i]\n\n";
            
            if( $lines[$i + 1] !~ /^\%mor:/ ) {
                print "\n-----\n\n";
            }
        }

        if( $lines[$i] =~ /^\%mor:/ ) {
            @mor = split '[ ~]', $lines[$i];
        }
        
        if( $lines[$i] =~ /^\%gra:/ ) {
            @gra = split '[ ~]', $lines[$i];

           shift @mor;
           shift @gra;

           my $ngra = @gra;
           my $nmor = @mor;

           if( $ngra != $nmor ) {
               print "Line $i: Length mismatch $ngra $nmor\n";
          }

        for( my $j = 0; $j < $nmor; $j++ ) {
            my $word = $mor[$j];
            my $lemma = $mor[$j];
            my $pos = "punct";
            my $morph = "_";

            if( $mor[$j] =~ /(.+)\|(.+)/ ) {
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

            if( $gra[$j] =~ /(.+)\|(.+)\|(.+)/ ) {
                $idx = $1;
                $headidx = $2;
                $gr = $3;
            }

            print "$idx\t$word\t$lemma\t$pos\t$pos\t$morph\t$headidx\t$gr\n";

        }
            print "\n-----\n\n";

    }

    if( /^\*/ ) {
        @mor = ();
        @gra = ();
    }
    
    }
}
