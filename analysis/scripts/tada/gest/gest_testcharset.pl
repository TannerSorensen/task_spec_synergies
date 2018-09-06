#!/usr/bin/perl

my $usage		= "\n useage: gest.pl <pdict> <seg2gest> <gparams> <onsets> <codas> <finals_wd> <finals_ph> <outfile> <orthog>\n\n";
my $pdict		= shift or die $usage;
my $seg2gest	= shift or die $usage;
my $gparamf		= shift or die $usage;
my $onsets		= shift or die $usage;
my $codas		= shift or die $usage;
my $finals_wd	= shift or die $usage;
my $finals_ph	= shift or die $usage;
my $outfile		= shift or die $usage;
my $orthog		= shift or die $usage;


open(IN, '< dict.txt') or die "Unable to open 'dict.txt': $!";
open(OUT, '> out.txt') or die "Unable to open 'out.txt': $!";

	while(<IN>) {
		chomp;
		print "$_\n";
		print OUT "$_\n";
	}
	print "$orthog\n";
	print OUT "$orthog\n";

close IN;
close OUT;
