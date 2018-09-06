#! /usr/bin/perl

=head1 NAME
 syllabify_dict.pl

=head1 SYNOPSIS
 Syllabify pronuniciation dictionary, indicating null onsets and codas.
    full syllable:	(o1-n1_c1)
    no onset:		(-n1_c1)
    no coda:		(o1-n1_)
    nucleus only:	(-n1_)

=head1 DESCRIPTION
 useage: syllabify_dict.pl <dictfile> <onsets> <outfile>
 <dictfile>	(string) text file mapping orthography -> phonetic string
 <onsetfile>(string) text file listing all syllable onsets in language
 <outfile>	(string) text file to write output: syllabified phonetic strings

=head1 BUGS
 none known

=head1 AUTHOR
 Michael Proctor <michael.proctor@yale.edu>

=cut

my $usage		= "\n useage: syllabify_dict.pl <dictfile> <onsetfile> <outfile>\n\n";
my $dictfile	= shift or die $usage;
my $onsetfile	= shift or die $usage;
my $outfile		= shift or die $usage;

#--- fetch list of onsets from file ---
my  %onsets;
print "\n  opening onset file  <$onsetfile> ... ";
open(FH_ONS, "< $onsetfile") or die "cannot open $onsetfile\n";
	while (<FH_ONS>) {
		if (/^([A-Z]+( [A-Z]+)*)$/) {
			$onsets{$1} = $1;
			print "  $1\n";
		}
	}
close (FH_ONS);
print keys( %onsets ) ." onsets found\n";

#--- fetch phonemic representations from pronunication dictionary ---
my  %pdict;
print "  opening pronunciation dictionary  <$dictfile> ... ";
open(FH_DICT, "< $dictfile") or die "cannot open $dictfile\n";
	while (<FH_DICT>) {
		if (/^([a-z]+)  ([A-Z0-9 ]+)$/) {
			$pdict{$1} = $2;
			print "  $1\t$2\n";
			$cnt++
		}
	}
close (FH_DICT);
print keys( %pdict ) ." pronunciations found\n";

#--- parse each phonemic word into syllables ---
my	$wd;
open(FH_OUT, "> $outfile")   or die "cannot open $outfile\n";

	foreach $wd (sort (keys (%pdict))) {
	
		(print FH_OUT "$wd\t") or die "cannot write to $outfile: $!";

		my $pron = $pdict{$wd};
		#print "\n   $wd\t$pron\n   ";
		my $sylcnt = 0;
		while ($pron =~ /(([A-Z]+ )*([A-Z]+))\d/g) {
			$sylcnt++;
			my $onsnuc = $1;
			my $nuc = $3;

			#--- no onset ---
			if ($2 eq "") {
				if ($sylcnt > 1) {
					(print FH_OUT ")") or die "cannot write to $outfile: $!";
				}
				(print FH_OUT "(-$nuc"."_") or die "cannot write to $outfile: $!";
			}
			
			#--- onset (+previous coda?) and nucleus ---
			else {
				$onsnuc =~ /^(.*)( [A-Z]+)$/;
				$ons = $1;
				$prevcod = "";
				while (!($onsets{$ons}) && ($ons ne "")) {
					$ons =~ /^([A-Z]+)([ A-Z]+)*/;
					$prevcod = $prevcod." ".$1;
					$ons = $2;
					$ons =~ s/^ //;			# strip leading space
					$prevcod =~ s/^ //;
				}
				if ($sylcnt == 1) {
					(print FH_OUT "(") or die "cannot write to $outfile: $!";
				}
				else {
					(print FH_OUT $prevcod.")(") or die "cannot write to $outfile: $!";
				}
				(print FH_OUT "$ons"."-"."$nuc"."_") or die "cannot write to $outfile: $!";
			}
		}
		
		#--- final coda? ---
		$pron =~ /\d([ A-Z]+)+$/;
		my $coda = $1;
		$coda =~ s/^ //;	# strip leading space
		(print FH_OUT "$coda)\n") or die "cannot write to $outfile: $!";

	}
	(print FH_OUT "\n") or die "cannot write to $outfile: $!";

close (FH_OUT);
print "  \n\n";
