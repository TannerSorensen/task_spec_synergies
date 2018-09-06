#! /usr/bin/perl

=head1 NAME
 rhyme2coda.pl

=head1 SYNOPSIS
 extract list of codas from original gest rhymes file

=head1 DESCRIPTION
 useage: rhyme2coda.pl <sfinal_21.txt> <rhymes> <codas>
 <rhymes>	list of rhymes
 <codas>	list of codas

=head1 AUTHOR
 Michael Proctor <michael.proctor@yale.edu>

=cut

my $usage	= "\n  useage: rhyme2coda.pl <sfinal_21.txt> <rhymes> <codas>\n\n";
my $infile	= shift or die $usage;
my $rhymes	= shift or die $usage;
my $codas	= shift or die $usage;

my $cnt = 0;

print "\n  opening list of rhymes <$infile> ...\n";
open(FH_IN, "< $infile")  or die "cannot open $infile\n";

print "  creating rhymes file <$rhymes> ...\n";
open(FH_RYM, "> $rhymes") or die "cannot open $rhymes\n";

print "  creating codas file <$codas> ...\n";
open(FH_COD, "> $codas") or die "cannot open $codas\n";

	my $cnt_rym = 0;
	my @codas	= ();

	while (<FH_IN>) {

		if (/^([a-z]+) .+/) {
		
			my $rhyme = $1;
			(print FH_RYM "$rhyme\n") or die "cannot write to $rhymes: $!";
			$cnt_rym++;
			
			if ($rhyme =~ /^([a-z]{2})([a-z]*)/) {
				if ( $2 ne "" ) { push @codas, $2;	}
			}

		}

	}
	
	# remove duplicate codas
	undef %saw;
	@unique_codas = grep(!$saw{$_}++, @codas);
	
	my $cnt_cod = 0;
	foreach $coda (@unique_codas) {
		(print FH_COD "$coda\n") or die "cannot write to $codas: $!";
		$cnt_cod++;
	}
	
	print "\n  $cnt_rym rhymes and";
	print "\n  $cnt_cod codas found\n\n";

close (FH_COD);
close (FH_RYM);
close (FH_IN);

