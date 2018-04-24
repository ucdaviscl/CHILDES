#!/usr/bin/perl

use strict;

my $fname = shift;

open FP, $fname or die "Cannot open $fname\n";

my $str = "";

while(<FP>) {
    $str .= $_;
}

my @lines = split "\n", $str;
my @output = ();
my %cols = (); # hash of arrays, so that we can access data for any line in the table

my $to_idx = 0;
my $to_prep = 0;
my $common_noun = 0;

# divide CoNLL formatted text into columns
for(my $i = 0; $i < @lines; $i++) {
    @{$cols{$i}} = split "\t", $lines[$i];

    push @output, $lines[$i];

    # check to see if token immediately following "to" is a common noun
    if($i == $to_idx + 1) {
        if($cols{$i}->[3] =~ /\bn\b/) {
            $common_noun = 1;
        }
    }
    # filter out utterances containing the infinitive marker "to"
    # invalidly tagged as a preposition
    # these structures often look like "to" + COMMON_NOUN
    # where COMMON_NOUN is designated by an "n" POS
    # in some cases, the COMMON_NOUN is actually an infinitive verb
    # this filter is not perfect, but does cover (all?) incorrectly-marked cases of "to"
    if( $cols{$i}->[3] =~ /prep/ && $cols{$i}->[2] =~ /\bto\b/) {
        $to_prep = 1;
        $to_idx = $i;
    }

    if($lines[$i] =~ /\-\-\-\-\-/) {
        # filter out invalidly-tagged utterances:
        # these utterances include those from bookreading corpora
        # as well as utterances containing the infinitive marker "to"
        # incorrectly tagged as a preposition

        if($output[7] !~ /(.+(\/BR\/)|(\/RE\/).+)/ && $output[7] !~ /.+\/HV7\/LW\/.+/) {
            # only print utterance to file if it is deemed valid
            if($common_noun == 0) {
                for(my $j = 1; $j < @output; $j++) {
                        print "$output[$j]\n";
                }
            }
        }
        @output = ();
        $to_prep = 0;
        $common_noun = 0;
        $to_idx = 0;
    }
}

