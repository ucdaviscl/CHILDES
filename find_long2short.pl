#!/usr/bin/perl

use strict;
use File::Find;

my $dirname = shift;

my @flist = <$dirname/*.txt>;

my $outfile = "output.txt";
    
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
  my $child_sentence = 0; # flag variable that is false initially
  my $length = 0;
  my $difference = 0;
  
  my @phrase_idxs = ();
  my @lengths = ();
  my @output = ();
  my @stack = ();
  my @cols = ();
  my @mins = (); 


  my $child_long2short_count = 0;
  my $long2short_count = 0; # len1 - len2 > 0

    # get length of sentence
    for( my $k = 0; $k < @lines; $k++ ) {
        @cols = split "\t", $lines[$k];
        
    	if( $cols[0] =~ /^\d/ ) {
    		$min++;
    	}
    	
    		if( $lines[$k] =~ /\-\-\-\-\-/ ) {
    			push @mins, $min;
    			$min = 0;
    		}
   	}

  # divide CoNLL formatted text into columns
  
  my $idx = 0;
  
  for( my $i = 0; $i < @lines; $i++ ) {
    @cols = split "\t", $lines[$i];
    
    push @output, $lines[$i];
        
    if ( $cols[3] =~ /prep/ ) {
    	push @phrase_idxs, $cols[0];

    	for( my $j = $i + 1; $j < @lines; $j++ ) {
    	    @cols = split "\t", $lines[$j];
    	
    		if( $cols[7] =~ /POBJ/ ) {
    			push @phrase_idxs, $cols[0];	
    			push @stack, $cols[0];
    			
    			last;
    		}
    		 push @phrase_idxs, $cols[0];

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
    
    # if child utterance, set flag variable
    if( index( $lines[$i], "*CHI" ) != -1 ) {
    	$child_sentence = 1;
    }
    
    if( $lines[$i] =~ /\-\-\-\-\-/ ) {
        $difference = $lengths[0] - $lengths[1];
        $idx++;

        if( $difference > 0 ) {
        
            if( $child_sentence == 1 ) {
        	    print $fh "child_long2short_count + 1\n";
        		$child_long2short_count++;
        		print $fh "child long2short: $child_long2short_count\n";
        	}
        	
        	else {
        		print $fh "long2short count + 1\n";
        		$long2short_count++;
        		print $fh "long2short: $long2short_count\n";
        	}
        	
            for( my $k = 1; $k < @output; $k++ ) {
          	  	print $fh "$output[$k]\n";
          	}
          	
          	print $fh "\n";
        }

        # clear arrays for next utterance
        @lengths = (); 
        @output = ();
        
        # reset flag for next utterance
        $child_sentence = 0;

		#print $fh "\n-----\n";
		
    	next;
    }
  } 
}