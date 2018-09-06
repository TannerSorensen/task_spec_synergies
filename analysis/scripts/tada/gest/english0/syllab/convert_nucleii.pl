#! /usr/bin/perl

=head1 NAME
 convert_nucleii.pl

=head1 SYNOPSIS
 convert complex nucleii to single monophthongal nucleus + glide-initial coda

=head1 DESCRIPTION
 useage: convert_nucleii.pl <infile> <outfile>
 <infile>	(string) syllabified pronunciation dictionary
 <outfile>	(string) re-analysed pronunciation dictionary

=head1 BUGS
 none known

=head1 AUTHOR
 Michael Proctor <michael.proctor@yale.edu>

=cut

my $usage	= "\n  useage: convert_nucleii.pl <dictfile> <outfile>\n\n";
my $dictfile = shift or die $usage;
my $outfile	 = shift or die $usage;

my $cnt = 0;

print "\n  opening dictionary file <$dictfile> ...\n";
open(FH_DICT, "< $dictfile")  or die "cannot open $dictfile\n";

print "  creating new dictionary file <$outfile> ...\n";
open(FH_NEW, "> $outfile") or die "cannot open $outfile\n";

	my $cnt = 0;
	while (<FH_DICT>) {

		s/-AW([0-4])_/-AA$1_W /g;				# AW -> AA_W
		s/-AY([0-4])_/-AA$1_Y /g;				# AY -> AA_Y
		s/-OY([0-4])_/-AO$1_Y /g;				# OY -> AO_Y

		s/_([RWY]) \)/_$1\)/g;					# clean up coda-less syllables
		s/_([RWY]) $1/_$1/g;					# clean up doubled approximants

		(print FH_NEW "$_") or die "cannot write to $outfile: $!";
		$cnt++;

	}
	print "  $cnt pronunciations found\n\n";

close (FH_NEW);
close (FH_DICT);
