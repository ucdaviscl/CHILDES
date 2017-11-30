#!/usr/bin/perl

use strict;
use File::Find;

my $dirname = shift;

my @flist = <$dirname/*.txt>;

my $outfile = "parent_non_violating.txt";

open my $fh, '>', $outfile or die "Cannot open $outfile\n";

foreach my $fname ( @flist ) {
  open FP, $fname or die "Cannot open $fname\n";

  my $str = "";

  while( <FP> ) {
    $str .= $_;
  }

  my @lines = split "\n", $str;

  my $min = 0;
  my $max = 1;
  my $dep;
  my $item;
  my $length = 0;
  my $difference = 0;

  my @phrase_idxs = ();
  my @lengths = ();
  my @output = ();
  my @stack = ();
  my %cols = (); # hash of arrays
  my @mins = ();

    # get length of sentence
    for( my $k = 0; $k < @lines; $k++ ) {
        @{$cols{$k}} = split "\t", $lines[$k];


        if( $cols{$k}->[0] =~ /^\d/ ) {
            $min++;
        }

            if( $lines[$k] =~ /\-\-\-\-\-/ ) {
                push @mins, $min;
                $min = 0;
            }
    }

  my $idx = 0;

  for( my $i = 0; $i < @lines; $i++ ) {
    push @output, $lines[$i];

    if ( $cols{$i}->[3] =~ /prep/ ) {
        push @phrase_idxs, $cols{$i}->[0];

        # if immediately preceded by adv with same head as prep, push adv index
        if( $cols{$i - 1}->[3] =~ /adv/ && $cols{$i - 1}->[6] == $cols{$i}->[6] ) {
            push @phrase_idxs, $cols{$i - 1}->[0];
        }

        for( my $j = $i + 1; $j < @lines; $j++ ) {
            if( $cols{$j}->[7] =~ /POBJ/ ) {
                push @phrase_idxs, $cols{$j}->[0];
                push @stack, $cols{$j}->[0];

                last; # break
            }

             push @phrase_idxs, $cols{$j}->[0];
        }

        $min = $mins[$idx];

         while( @stack ) {
            $item = pop @stack;

            if( $item > $max ) {
                $max = $item;
            }

            if( $item < $min ) {
                $min = $item;
            }

            if( @phrase_idxs ) {
                $dep = pop @phrase_idxs;
                push @stack, $dep;
            }
        }

        $length = $max - $min;

        push @lengths, $length;

        $max = 0;
    }

	# print all utterances not in violation of our dependency rule
    if( $lines[$i] =~ /\-\-\-\-\-/ ) {
        $difference = $lengths[0] - $lengths[1];
        $idx++;

        if( ( $difference < 0 ) || ( $difference == 0 ) ) {
            print $fh "difference in length: $difference\n";

            for( my $k = 1; $k < @output; $k++ ) {
                print $fh "$output[$k]\n";
            }

            print $fh "\n";
        }

        # clear arrays for next utterance
        @lengths = ();
        @output = ();

        next;
    }
  }
}