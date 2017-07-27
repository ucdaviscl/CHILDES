#!/usr/bin/perl

use strict;

my $dirname = shift;

my @flist = <$dirname/*.txt>;

# output child and adult utterances to different files
my $outfile1 = "childresults.txt";
my $outfile2 = "adultresults.txt";
    
open my $fh1, '>', $outfile1 or die "Cannot open $outfile1\n";
open my $fh2, '>', $outfile2 or die "Cannot open $outfile2\n";

my $childcount = 0;

foreach my $fname ( @flist ) {
  open FP, $fname or die "Cannot open $fname\n";

  my $str = "";

  while( <FP> ) {
    $str .= $_;
  }

  # each @lines index contains a line of CoNLL formatted text
  my @lines = split "\n", $str;
  my @output = ();
  my @heads = ();
  
  my $prepcount = 0;
  my $pobjcount = 0;
  my $matchcount = 0;

  # divide CoNLL formatted text into columns
  for( my $i = 0; $i < @lines; $i++ ) {
    my @cols = split "\t", $lines[$i];

    push @output, $lines[$i];

    # ----- denotes the end of an utterance "block"
    if( $lines[$i] =~ /\-\-\-\-\-/ ) {

      # if there are exactly 2 prepositional phrases in a block
      # iterate over their heads and look for a match
      # display utterance info. and update counter if match found
      if ( $prepcount =~ 2 ) {
      
      	# each preposition must have a corresponding POBJ
      	if( $pobjcount =~ 2) {
        	my %match;

        	foreach my $head ( @heads ) {
        	  next unless $match{ $head }++;

          	  $matchcount++;

			  # if child utterance
          	  if( index( $output[3], "*CHI" ) != -1 ) {
          	  	$childcount++;
          	           	  	
          	  	print $fh1 "child count: $childcount\n";
          	    print $fh1 "\n# Match #$matchcount\n";
          	  	print $fh1 "# Line: $i\n";
          	  	print $fh1 "# The count is: $prepcount\n";
          	  	print $fh1 "# The heads are: @heads\n";
          	  	print $fh1 "# The POBJ count is: $pobjcount\n";
          	  	
          	  	for( my $j = 1; $j < @output; $j++ ) {
          	  	    print $fh1 "$output[$j]\n";
          	  	}
          	  }
          	  
          	  # if adult utterance
          	  else {                  	  	
          	  	print $fh2 "\n# Match #$matchcount\n";
          	  	print $fh2 "# Line: $i\n";
          	  	print $fh2 "# The count is: $prepcount\n";
          	  	print $fh2 "# The heads are: @heads\n";
          	  	print $fh2 "# The POBJ count is: $pobjcount\n";
          	  	
          	  	for( my $j = 1; $j < @output; $j++ ) {
          	  	    print $fh2 "$output[$j]\n";
          	  	}
          	  }

         	   # break and clear @output for next utterance if match found
          	  @output = ();
          	  last;
        	}
        	
        	@output = ();
        }
        
        @output = ();
      }

      else {
        @output = ();
      }

      # reset prepcount and pobjcount and clear @heads for next utterance
      $prepcount = 0;
      $pobjcount = 0;
      @heads = ();
    }

    # if the current word is a preposition
    if( $cols[3] =~ /prep/ ) {
      $prepcount++;
      push @heads, $cols[6];
    }
    
    if( $cols[7] =~ /POBJ/ ) {
    	$pobjcount++;
	}
  }

  print "\n";
}