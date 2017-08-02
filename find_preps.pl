#!/usr/bin/perl

use strict;

my $dirname = shift;

my @flist = <$dirname/*.txt>;

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
	my $matchcount = 0;

	for( my $i = 0; $i < @lines; $i++ ) {
		
		# divide CoNLL formatted text into columns
		my @cols = split "\t", $lines[$i];

		push @output, $lines[$i]; # output buffer

		# ----- denotes the end of an utterance "block"
		if( $lines[$i] =~ /\-\-\-\-\-/ ) {

			# if there are 2+ prepositional phrases in a block
			# iterate over their heads and look for at least one match
			# display utterance info. and update counter if match found
			if ( $prepcount > 1 ) {
				my %match;

				foreach my $head ( @heads ) {
					
					# continue iterating unless we find a match
					next unless $match{ $head }++;

					$matchcount++;

					print "\nMatch #$matchcount\n";\
					print "Line: $i\n";
					print "\nThe count is: $prepcount";
					print "\nThe heads are: @heads\n";
					
					# print phrase details in CoNLL format
					for( my $j = 1; $j < @output; $j++ ) {
						print "$output[$j]\n";
					}

					# break and clear @output for next utterance if match found
					@output = ();
					last;
				}
			}

			else {
				@output = ();
			}

			# reset prepcount and clear @heads for next utterance
			$prepcount = 0;
			@heads = ();
		}

		# if the current word is a preposition
		if( $cols[3] =~ /prep/ ) {
			$prepcount++;
			push @heads, $cols[6];
		}
	}

	print "\n";
}
