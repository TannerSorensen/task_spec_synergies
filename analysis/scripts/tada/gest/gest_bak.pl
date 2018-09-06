#!/usr/bin/perl


=head1 NAME
 gest.pl

=head1 SYNOPSIS
 Convert English orthography/ARPAbet syllabic notation to gestural specification.
 Treats onset clusters as sequences of constituent segments, modified by the addition or deletion of
 any cluster-specific gestures specified in <onsets>.
 Treats codas as sequences of segments sharing a single glottal gesture or as orally-unreleased nasals.
 Allows use of post-vocalic integers to indicate stress.

=head1 DESCRIPTION
 useage: gest.pl <pdict> <seg2gest> <gparams> <onsets> <codas> <outfile> <orthog>
 <pdict>	(string) text file mapping orthography -> syllabified phonetic string
 <seg2gest>	(string) text file mapping phones -> gestures
 <gparams>	(string) text file specifiying targets and other parameters for each TV-constriction pair
 <onsets>	(string) text file listing any gestures to add or delete from onset clusters
 <codas>	(string) text file listing any gestures to add or delete from coda clusters
 <finals_wd>(string) text file listing any gestures to add or delete from word-final coda clusters
 <finals_ph>(string) text file listing any gestures to add or delete from phrase-final coda clusters
 <outfile>	(string) text file in which to write output (tada TV*.O input file)
 <orthog>	(string) input string:	lower case English orthography/upper case ARPAbet
 									syllables delimited by ():			(LAA1YK)(DHIHS)
 									multiple words delimited by #:		like#this
 									multiple phrases delimited by ##:	like#this##new#phrase

=head1 BUGS
 none known

=head1 AUTHOR
 Michael Proctor <michael.proctor@yale.edu>

=head1 REVISION
 Created:	06-Nov-06	MP
 Updated:	12-Aug-08	Added additional <finals> input file to include utterance-final coda deletion rules
 Updated:	23-Sep-08	Added additional <finals_wd> input file to specify word-final coda deletion rules
 						Allowed <##> seperator in input string to specify phrase boundaries at which <finals> rules apply

=cut

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

#-------------------------------------------------------------------------
#-------------     define constants and data classes    ------------------
#-------------------------------------------------------------------------

#enumerate parts of syllable
@syllstruct	= ( "onset", "nucleus", "coda" );

#enumerate arpabet as hash for easy parsing of clusters
%arpabet	= (	B, B, P, P, M, M, D, D, T, T, N, N, G, G, K, K, NX, NX, 
				V, V, F, F, DH, DH, TH, TH, Z, Z, S, S, ZH, ZH, SH, SH, JH, JH, CH, CH, 
				Y, Y, W, W, R, R, L, L, HH, HH, Q, Q, 
				IY, IY, IH, IH, EY, EY, EH, EH, AE, AE, AA, AA, AO, AO, UW, UW, UH, UH, 
				OW, OW, AX, AX, ER, ER, AH, AH, AW, AW, AY, AY, OY, OY,
				X, X, GX, GX, NY, NY, RR, RR, A, A, I, I, E, E, U, U, O, O);

#enumerate classes as hashes for application of gestural rules
%vowel		= (	IY, IY, IH, IH, EY, EY, EH, EH, AE, AE, AA, AA, AO, AO, UW, UW, 
				UH, UH, OW, OW, AX, AX, ER, ER, AH, AH, AW, AW, AY, AY, OY, OY );
%glottal	= (	GLO, GLO );

#define set of regexes to simplify parsing of long strings
$C		= "B|P|M|D|T|N|G|K|V|F|S|Z|Y|W|R|L";
$D		= "NX|DH|TH|ZH|SH|JH|CH|HH";
$n		= "[0-9-\.]+";
$uc		= "[A-Z_]+";
$lc		= "[a-z_]+";
$cl		= "[A-Z\.]+";
$snuc	= "[A-Z0-4]+";			# nucleus (allow integer denoting stress)


#-------------------------------------------------------------------------
#-------------     load external data from files        ------------------
#-------------------------------------------------------------------------

#fetch phonemic representations from syllabified pronunication dictionary
my  %pdict;
print "\n  opening dictionary file     <$pdict> ...     ";
open(FH_DICT, "< $pdict") or die "cannot open $pdict\n";
	my $cnt = 0;
	while (<FH_DICT>) {
		if (/^($lc)\s+([A-Z0-4_\-\(\) ]+)/) {
			#print "\n  $1\t$2";
			$pdict{$1} = $2;
			$cnt++;
		}
	}
close (FH_DICT);
print "$cnt pronunciations found\n";

#fetch list of onset cluster rules
my  %ons_rules;
print "  opening onsets file         <$onsets> ...    ";
open(FH_CLUST, "< $onsets") or die "cannot open $onsets\n";
	my $rule_cnt = 0;
	while (<FH_CLUST>) {
		#      (1ARPA) (2C)    (3TV)   (4Con)   (5Tar) (6Stf) (7Dmp) (8Alp) (9LX)  (10JA) (11UH) (12LH) (13CL) (14CA) (15TL) (16TA) (17NA) (18GW)
		if ( /^($uc)\s+($uc)\s+($uc)\s+($uc)(\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n))*/ ) {
			$CC = $1; $Ct = $2; $TV = $3; $CN = $4; $pars = $5;
			$Tar = $6; $Stf = $7; $Dmp = $8; $Alp = $9;
			$LX = $10; $JA = $11; $UH = $12; $LH = $13; $CL = $14;
			$CA = $15; $TL = $16; $TA = $17; $NA = $18; $GW = $19;
			my $clust = parse_clust($CC);
			$clust =~ /^($uc)( $uc)*$/;
			$C1 = $1; $C2 = $2;	$C2 =~ s/^ //;
			if	(($C2 eq ""))	{ $C2 = "*" }
			my $rule = {
				ID    => $cnt++,
				C1	  => $C1,
				C2	  => $C2,
				Ct	  => $Ct,
				TV	  => $TV,
				CONS  => $CN,
				TARG  => $Tar,
				STIF  => $Stf,
				DAMP  => $Dmp,
				ALPH  => $Alp,
				LX	  => $LX,
				JA    => $JA,
				UH    => $UH,
				LH    => $LH,
				CL    => $CL,
				CA    => $CA,
				TL    => $TL,
				TA    => $TA,
				NA    => $NA,
				GW    => $GW
			};
			#print "  $rule->{C1}\t$rule->{C2}\t$rule->{Ct}\t$rule->{TV}\t$rule->{CONS}\t$rule->{TARG}\t$rule->{STIF}\t";
			#print "$rule->{DAMP}\t$rule->{ALPH}\tLX$rule->{LX}\tJA$rule->{JA}\tUH$rule->{UH}\tLH$rule->{LH}\tCL$rule->{CL}\t";
			#print "CA$rule->{CA}\tTL$rule->{TL}\tTA$rule->{TA}\tNA$rule->{NA}\tGW$rule->{GW}\n";
			$ons_rules{ $rule->{ID}	} = $rule;
			$rule_cnt++;
		}
	}
close (FH_CLUST);
print "$rule_cnt onset cluster rules found\n";

#fetch list of coda cluster rules
my  %cod_rules;
print "  opening codas file          <$codas> ...     ";
open(FH_CLUST, "< $codas") or die "cannot open $codas\n";
	$rule_cnt = 0;
	while (<FH_CLUST>) {
		#      (1ARPA) (2C)    (3TV)   (4Con)   (5Tar) (6Stf) (7Dmp) (8Alp) (9LX)  (10JA) (11UH) (12LH) (13CL) (14CA) (15TL) (16TA) (17NA) (18GW)
		if ( /^($uc)\s+($uc)\s+($uc)\s+($uc)(\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n))*/ ) {
			$CC = $1; $Ct = $2; $TV = $3; $CN = $4; $pars = $5;
			$Tar = $6; $Stf = $7; $Dmp = $8; $Alp = $9;
			$LX = $10; $JA = $11; $UH = $12; $LH = $13; $CL = $14;
			$CA = $15; $TL = $16; $TA = $17; $NA = $18; $GW = $19;
			my $clust = parse_clust($CC);
			$clust =~ /^($uc)( $uc)*$/;
			$C1 = $1; $C2 = $2;	$C2 =~ s/^ //;
			if	(($C2 eq ""))	{ $C2 = "*" }
			my $rule = {
				ID    => $cnt++,
				C1	  => $C1,
				C2	  => $C2,
				Ct	  => $Ct,
				TV	  => $TV,
				CONS  => $CN,
				TARG  => $Tar,
				STIF  => $Stf,
				DAMP  => $Dmp,
				ALPH  => $Alp,
				LX	  => $LX,
				JA    => $JA,
				UH    => $UH,
				LH    => $LH,
				CL    => $CL,
				CA    => $CA,
				TL    => $TL,
				TA    => $TA,
				NA    => $NA,
				GW    => $GW
			};
			#print "  $rule->{C1}\t$rule->{C2}\t$rule->{Ct}\t$rule->{TV}\t$rule->{CONS}\t$rule->{TARG}\t$rule->{CL}\t$rule->{GW}\n";
			$cod_rules{ $rule->{ID}	} = $rule;
			$rule_cnt++;
		}
	}
close (FH_CLUST);
print "$rule_cnt coda rules found\n";

#fetch list of word-final coda cluster rules
my  %wd_fin_rules;
print "  opening word finals file    <$finals_wd> ... ";
open(FH_CLUST, "< $finals_wd") or die "cannot open $finals_wd\n";
	$rule_cnt = 0;
	while (<FH_CLUST>) {
		#      (1ARPA) (2C)    (3TV)   (4Con)   (5Tar) (6Stf) (7Dmp) (8Alp) (9LX)  (10JA) (11UH) (12LH) (13CL) (14CA) (15TL) (16TA) (17NA) (18GW)
		if ( /^($uc)\s+($uc)\s+($uc)\s+($uc)(\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n))*/ ) {
			$CC = $1; $Ct = $2; $TV = $3; $CN = $4; $pars = $5;
			$Tar = $6; $Stf = $7; $Dmp = $8; $Alp = $9;
			$LX = $10; $JA = $11; $UH = $12; $LH = $13; $CL = $14;
			$CA = $15; $TL = $16; $TA = $17; $NA = $18; $GW = $19;
			my $clust = parse_clust($CC);
			$clust =~ /^($uc)( $uc)*$/;
			$C1 = $1; $C2 = $2;	$C2 =~ s/^ //;
			if	(($C2 eq ""))	{ $C2 = "*" }
			my $rule = {
				ID    => $cnt++,
				C1	  => $C1,
				C2	  => $C2,
				Ct	  => $Ct,
				TV	  => $TV,
				CONS  => $CN,
				TARG  => $Tar,
				STIF  => $Stf,
				DAMP  => $Dmp,
				ALPH  => $Alp,
				LX	  => $LX,
				JA    => $JA,
				UH    => $UH,
				LH    => $LH,
				CL    => $CL,
				CA    => $CA,
				TL    => $TL,
				TA    => $TA,
				NA    => $NA,
				GW    => $GW
			};
			#print "  $rule->{C1}\t$rule->{C2}\t$rule->{Ct}\t$rule->{TV}\t$rule->{CONS}\t$rule->{TARG}\t$rule->{CL}\t$rule->{GW}\n";
			$wd_fin_rules{ $rule->{ID}	} = $rule;
			$rule_cnt++;
		}
	}
close (FH_CLUST);
print "$rule_cnt word-final rules found\n";

#fetch list of phrase-final coda cluster rules
my  %ph_fin_rules;
print "  opening phrase finals file  <$finals_ph> ... ";
open(FH_CLUST, "< $finals_ph") or die "cannot open $finals_ph\n";
	$rule_cnt = 0;
	while (<FH_CLUST>) {
		#      (1ARPA) (2C)    (3TV)   (4Con)   (5Tar) (6Stf) (7Dmp) (8Alp) (9LX)  (10JA) (11UH) (12LH) (13CL) (14CA) (15TL) (16TA) (17NA) (18GW)
		if ( /^($uc)\s+($uc)\s+($uc)\s+($uc)(\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n))*/ ) {
			$CC = $1; $Ct = $2; $TV = $3; $CN = $4; $pars = $5;
			$Tar = $6; $Stf = $7; $Dmp = $8; $Alp = $9;
			$LX = $10; $JA = $11; $UH = $12; $LH = $13; $CL = $14;
			$CA = $15; $TL = $16; $TA = $17; $NA = $18; $GW = $19;
			my $clust = parse_clust($CC);
			$clust =~ /^($uc)( $uc)*$/;
			$C1 = $1; $C2 = $2;	$C2 =~ s/^ //;
			if	(($C2 eq ""))	{ $C2 = "*" }
			my $rule = {
				ID    => $cnt++,
				C1	  => $C1,
				C2	  => $C2,
				Ct	  => $Ct,
				TV	  => $TV,
				CONS  => $CN,
				TARG  => $Tar,
				STIF  => $Stf,
				DAMP  => $Dmp,
				ALPH  => $Alp,
				LX	  => $LX,
				JA    => $JA,
				UH    => $UH,
				LH    => $LH,
				CL    => $CL,
				CA    => $CA,
				TL    => $TL,
				TA    => $TA,
				NA    => $NA,
				GW    => $GW
			};
			#print "  $rule->{C1}\t$rule->{C2}\t$rule->{Ct}\t$rule->{TV}\t$rule->{CONS}\t$rule->{TARG}\t$rule->{CL}\t$rule->{GW}\n";
			$ph_fin_rules{ $rule->{ID}	} = $rule;
			$rule_cnt++;
		}
	}
close (FH_CLUST);
print "$rule_cnt phrase-final rules found\n";

#fetch gestural representations into hash of gestural database
my  %gbase;
print "  opening gestural file       <$seg2gest> ...  ";
open(FH_GEST, "< $seg2gest") or die "cannot open <$seg2gest>\n";
	$cnt = 0;
	$phone_cnt = 0;
	$last_phone = "";
	while (<FH_GEST>) {
		#      (1ARPA) (2Org)  (3Osc)  (4TV)   (5Con)  (6Tar) (7Stf) (8Dmp) (9Alp) (10LX) (11JA) (12UH) (13LH) (14CL) (15CA) (16TL) (17TA) (18NA) (19GW)
		if ( /^($uc)\s+(\w+)\s+($lc)\s+($uc)\s+($uc)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)/ ) {
			$phon_g = {
				ID    => $cnt++,
				APRA  => $1,
				OSC   => $3,
				TV	  => $4,
				CONS  => $5,
				TARG  => $6,
				STIF  => $7,
				DAMP  => $8,
				ALPH  => $9,
				LX	  => $10,
				JA    => $11,
				UH    => $12,
				LH    => $13,
				CL    => $14,
				CA    => $15,
				TL    => $16,
				TA    => $17,
				NA    => $18,
				GW    => $19
			};
			if ($phon_g->{APRA} ne $last_phone) {$phone_cnt++; $last_phone = $phon_g->{APRA};}
			#print "  $phone_cnt\t$phon_g->{APRA}\t$phon_g->{OSC}\t$phon_g->{TV}\t$phon_g->{CONS}\t$phon_g->{TARG}\t$phon_g->{STIF}\n";
			$gbase{ $phon_g->{ID}   } = $phon_g;
		}
	}
close (FH_GEST);
print keys(%gbase) ." gestures found for $phone_cnt phones\n";
 
#fetch gestural parameters
my  %gparams;
print "  opening parameter file      <$gparamf> ...   ";
open(FH_GPARAM, "< $gparamf") or die "cannot open $gparamf\n";
	$cnt = 0;
	$tv_cnt = 0;
	$last_tv = "";
	while (<FH_GPARAM>) {
		#      (1TV)   (2Con)  (3Tar) (4Alp) (5LX)  (6JA)  (7UH)  (8LH)  (9CL)  (10CA) (11TL) (12TA) (13NA) (14GW)
		if ( /^($uc)\s+($uc)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)\s+($n)/ ) {
			$gp = {
				ID    => $cnt++,
				TV	  => $1,
				CONS  => $2,
				TARG  => $3,
				ALPH  => $4,
				LX	  => $5,
				JA    => $6,
				UH    => $7,
				LH    => $8,
				CL    => $9,
				CA    => $10,
				TL    => $11,
				TA    => $12,
				NA    => $13,
				GW    => $14
			};
			if ($gp->{TV} ne $last_tv) {$tv_cnt++; $last_tv = $gp->{TV};}
			#print "  $cnt\t$gp->{TV}\t$gp->{CONS}\t$gp->{TARG}\t$gp->{ALPH}\t$gp->{LX}\t$gp->{JA}\n";
			$gparams{ $gp->{ID}   } = $gp;
		}
	}
close (FH_GPARAM);
print "$cnt parameters specified for $tv_cnt tract varaibles\n\n";


#-------------------------------------------------------------------------
#-------------     parse input string                   ------------------
#-------------------------------------------------------------------------

#split input string into separate phrases if necessary:
print "  1st parse of input string <$orthog> ... ";
	@phrases	= split( /##/, $orthog);
	$no_phrases	= @phrases;
	print "found $no_phrases phrase(s)\n\n";


#-------------------------------------------------------------------------
#-------------     create gestural score                ------------------
#-------------------------------------------------------------------------

#process input: orthography > phones > gestures

my	$wd_phon;
my	$wd_tot = 0;		# words counted over entire input string
my	$syll_tot = 1;		# syllables counted over entire input string

open(FH_OUT, "> $outfile.O")   or die "cannot open TV$outfile.O\n";

	#first line of gestural specification file: time/frame ... end frame (msec)
	my $frame_dur	= 10;
	my $frame_last	= 0;
	(print FH_OUT "$frame_dur $frame_last\n\n") or die "cannot write to $outfile: $!";
    (print FH_OUT "% Input string:\t<$orthog>\n%\n") or die "cannot write to $outfile: $!";

	#for each phrase in input string:
	my $phrase_no	= 0;
	foreach $phrase (@phrases) {

		$phrase_no++;
		$wd_cnt = 0;
		#split input string into separate words if necessary:
		print "  parsing phrase $phrase_no  <$phrase>  ...  ";
		@words	= split( /#/, $phrase);
		$no_wds	= @words;
		print "found $no_wds word(s)\n\n";

		#for each word in input string:
		my	$syll_cnt = 1;		# word-level syllable count
		foreach $wd_orth (@words) {

			$wd_cnt++;
			$wd_tot++;

			#fetch syllabic-phonemic representation of orthography
			$wd_phon = $pdict{$wd_orth};
			print "  Word $wd_tot:\t$wd_orth";
			if ($wd_phon eq "") {
				print "  not found in <$pdict>  -> treating as ARPAbet\n\n";
				# convert each parenthesis-delineated syllable into ARPAbet: (syll1)...(sylln):
				while ( $wd_orth =~ /\(([\w]+)\)/g ) {
					my $ARPA_syll = parse_ARPA_str($1);
					$wd_phon .= "($ARPA_syll)";
				}
			}
			else {
				print "\n  ARPAbet:\t$wd_phon\n\n";
			}

			(print FH_OUT "%\n") or die "cannot write to $outfile: $!";
			(print FH_OUT "% Word $wd_tot:\t$wd_orth\n") or die "cannot write to $outfile: $!";
			(print FH_OUT "% arpabet:\t$wd_phon\n") or die "cannot write to $outfile: $!";
			(print FH_OUT "%\n") or die "cannot write to $outfile: $!";

			# check number of syllables in word about to be parsed:
			my $no_syll = $1;
			while ( $wd_phon =~ /([\w\- ]+)/g ) {
				$no_syll++;
			}
			#print "\n  $no_syll syllables counted in <$wd_phon>\n";

			# parse word by syllable:
			while ( $wd_phon =~ /([\w\- ]+)/g ) {

				my $syll = $1;									# syll =   ons-nuc_cod
				$syll =~ /^([A-Z ]*)\-($snuc)_([A-Z ]*)$/;		# parse as (ons)-nucX_(cod)
				print "\n  syllable $syll_tot:\t$syll\n";
				(print FH_OUT "%\n% syllable $syll_tot:\t$syll\n") or die "cannot write to $outfile: $!";
				$ons = $1;
				$nuc = $2;
				$cod = $3;

				foreach my $syllpart (@syllstruct) {

					$onc = substr($syllpart, 0, 3);
					if ( $$onc ) {

						my $cluster = $$onc;
						my $seg_cnt = 0;
						my $last_seg = "";
						my $next_seg = "";

						print "\n    $syllpart cluster = <$cluster>\n";
						(print FH_OUT "%\n%    $syllpart cluster = <$cluster>\n") or die "cannot write to $outfile: $!";
						while ( $cluster =~ /($uc)/g ) {

							if ( $arpabet{$1} ) {

								my $seg = $1;
								$next_seg = "";
								if ( $cluster =~ /($seg) ($uc)/ ) {	$next_seg = $2;	}
								if ( ($last_seg ne "") && ($cluster =~ /($last_seg) ($seg)$/) ) {	$next_seg = "";	}

								print "    segment ". ++$seg_cnt . " [$seg]:\n";
								#print "    segment ". ++$seg_cnt . " [$seg]: (last=$last_seg next=$next_seg)\n";
								(print FH_OUT "%    segment ". $seg_cnt . " [$seg]:\n") or die "cannot write to $outfile: $!";

								# fetch all gestures for this segment from database:
								@seg_gests = ();
								foreach $phon_g (values %gbase) {
									if ($phon_g->{APRA} eq $seg) {
										#print "    $seg: $phon_g->{OSC}-$phon_g->{TV}-$phon_g->{CONS}\t$phon_g->{TARG}\t$phon_g->{STIF}\n";
										push @seg_gests, $phon_g;
									}
								}

								# fetch any rules for which this segment is (Ct && C2) of a cluster and $last_seg was C1
								#  ...         or for which this segment is (Ct && C1) of a cluster and $next_seg was C2:
								@seg_gdel	= ();
								@seg_mods	= ();
								if ($onc eq "ons") {
									foreach $rule (values %ons_rules) {
										if ( $rule->{Ct} eq $seg ) {
											if ( ($rule->{C1} eq $last_seg) && ($rule->{C2} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> onset cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> onset cluster\n";
													push @seg_gdel, $rule;
												}
											}
											elsif ( ($rule->{C2} eq $next_seg) && ($rule->{C1} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> onset cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> onset cluster\n";
													push @seg_gdel, $rule;
												}
											}
											elsif ( ($rule->{C2} eq "*") && ($rule->{C1} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg> onset cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg> onset cluster\n";
													push @seg_gdel, $rule;
												}
											}
										}
									}
								}
								elsif ($onc eq "cod") {
									#print "    -- coda cluster --\n";
									foreach $rule (values %cod_rules) {
										if ( $rule->{Ct} eq $seg ) {
											if ( ($rule->{C1} eq $last_seg) && ($rule->{C2} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> coda cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> coda cluster\n";
													push @seg_gdel, $rule;
												}
											}
											elsif ( ($rule->{C2} eq $next_seg) && ($rule->{C1} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> coda cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> coda cluster\n";
													push @seg_gdel, $rule;
												}
											}
											elsif ( ($rule->{C2} eq "*") && ($rule->{C1} eq $seg) ) {
												if ( $rule->{TARG} ) {
													print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg> coda cluster\n";
													push @seg_mods, $rule;
												}
												else {
													print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg> coda cluster\n";
													push @seg_gdel, $rule;
												}
											}
										}
									}
									if ($wd_cnt eq $no_wds) {
										#print "    -- phrase-final coda cluster --\n";
										foreach $rule (values %ph_fin_rules) {
											if ( $rule->{Ct} eq $seg ) {
												if ( ($rule->{C1} eq $last_seg) && ($rule->{C2} eq $seg) ) {
													#print "    -- <last_seg seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> phrase-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> phrase-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
												elsif ( ($rule->{C2} eq $next_seg) && ($rule->{C1} eq $seg) ) {
													#print "    -- <seg next_seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> phrase-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> phrase-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
												elsif ( ($rule->{C2} eq "*") && ($rule->{C1} eq $seg) ) {
													#print "    -- <seg next_seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg> phrase-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg> phrase-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
											}
										}
									}
									if ($syll_cnt eq $no_syll) {
										#print "    -- word-final coda cluster --\n";
										foreach $rule (values %wd_fin_rules) {
											if ( $rule->{Ct} eq $seg ) {
												if ( ($rule->{C1} eq $last_seg) && ($rule->{C2} eq $seg) ) {
													#print "    -- <last_seg seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> word-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$last_seg $seg> word-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
												elsif ( ($rule->{C2} eq $next_seg) && ($rule->{C1} eq $seg) ) {
													#print "    -- <seg next_seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> word-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg $next_seg> word-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
												elsif ( ($rule->{C2} eq "*") && ($rule->{C1} eq $seg) ) {
													#print "    -- <seg next_seg> --\n";
													if ( $rule->{TARG} ) {
														print "    modifying $rule->{TV} $rule->{CONS} gesture in <$seg> word-final coda cluster\n";
														push @seg_mods, $rule;
													}
													else {
														print "    deleting $rule->{TV} $rule->{CONS} gesture in <$seg> word-final coda cluster\n";
														push @seg_gdel, $rule;
													}
												}
											}
										}
									}
								}

								# now process all gestures for this segment
								my $new_seg = TRUE;
								foreach $phon_g (@seg_gests) {

									# fetch tract variable and constriction type for this gesture
									my $tv		= $phon_g->{TV};
									#print "    seg:   <$phon_g->{OSC}> <$tv> <$phon_g->{CONS}> <$phon_g->{TARG}> <$phon_g->{STIF}> <$phon_g->{DAMP}>";
									#print "LX<$phon_g->{LX}> JA<$phon_g->{JA}> CL<$phon_g->{CL}> CA<$phon_g->{CA}> TL<$phon_g->{TL}> TA<$phon_g->{TA}>\n";

									# fetch default parameters for this (TV,constriction type)
									my $params = "";
									foreach $gp (values %gparams) {
										if ($gp->{TV} eq $tv) {
											if ($gp->{CONS} eq $phon_g->{CONS}) { $params = $gp; last;	}
										}
									}
									if ( $params eq "" ) {
										print "    -- cannot find parameters for gesture: $seg $tv $constr --\n";
									}
									#print "    deflt:  <$params->{TV}> <$params->{CONS}> <$params->{TARG}> <$params->{ALPH}> ";
									#print "LX<$params->{LX}> JA<$params->{JA}> CL<$params->{CL}> CA<$params->{CA}> TL<$params->{TL}> TA<$params->{TA}>\n";

									# index gestures within appropriate segment and oscillator
									if ($onc eq "nuc") {
										$onctyp = $phon_g->{OSC};
									}
									else {
										if ( ($seg eq "L") && ($onc eq "cod") && ($phon_g->{OSC} ne "voc") ) {
											$onctyp = $onc.($seg_cnt+1)."_".$phon_g->{OSC};
										}
										else {
											$onctyp = $onc.$seg_cnt."_".$phon_g->{OSC};
										}
										end
									}

									# don't write gestures deleted from cluster by rule
									$seg_ok = TRUE;
									foreach $rule (@seg_gdel) {
										if ( ($tv eq $rule->{TV}) && ($phon_g->{CONS} eq $rule->{CONS}) ) {
											$seg_ok = 0; last
										}
									}
									# flag gestures to be modified by cluster-specific rule
									$seg_mod = 0;
									$mod_pars = "";
									foreach $rule (@seg_mods) {
										if ( ($tv eq $rule->{TV}) && ($phon_g->{CONS} eq $rule->{CONS}) ) {
											$seg_mod = TRUE;
											$mod_pars = $rule;
											last
										}
									}

									if ( $seg_ok ) {

										# otherwise: write gestural specs to file
										$string  = "\'$tv\' \'$onctyp$syll_tot\'";

										# fetch phone-specific TARGET, or use default value
										if ( $seg_mod )	{	$par = $mod_pars->{TARG};	}
										else			{	$par = $phon_g->{TARG};		}
										$par =~ s/^\.$/$params->{TARG}/;
										$string .= " $par";

										# fetch phone-specific STIFFNESS, or use defaults: f(C)=8; f(V)=4
										if ( $seg_mod )	{	$par = $mod_pars->{STIF};	}
										else			{	$par = $phon_g->{STIF};		}
										if ( $par eq "." )	{
											if ( $phon_g->{OSC} =~ /^v/ )	{ $par = "4"; }
											else							{ $par = "8"; }	
										}
										$string .= " $par";

										# fetch phone-specific DAMPING FACTOR, or use default value
										if ( $seg_mod )	{	$par = $mod_pars->{DAMP};	}
										else			{	$par = $phon_g->{DAMP};		}
										$par =~ s/^\.$/1/;
										$string .= " $par";

										# fetch default articulator weights
										my $aw = "";
										if ( $params->{LX} ne "." ) { $aw .= "LX=$params->{LX},"; }
										if ( $params->{JA} ne "." ) { $aw .= "JA=$params->{JA},"; }
										if ( $params->{UH} ne "." ) { $aw .= "UH=$params->{UH},"; }
										if ( $params->{LH} ne "." ) { $aw .= "LH=$params->{LH},"; }
										if ( $params->{CL} ne "." ) { $aw .= "CL=$params->{CL},"; }
										if ( $params->{CA} ne "." ) { $aw .= "CA=$params->{CA},"; }
										if ( $params->{TL} ne "." ) { $aw .= "TL=$params->{TL},"; }
										if ( $params->{TA} ne "." ) { $aw .= "TA=$params->{TA},"; }
										if ( $params->{NA} ne "." ) { $aw .= "NA=$params->{NA},"; }
										if ( $params->{GW} ne "." ) { $aw .= "GW=$params->{GW}"; }
										#print "    --aw=$aw--\n";

										# update articulator weights with any phone-specifed values
										if ( $phon_g->{LX} ne "." ) { $aw =~ s/(LX=)\d+/$1$phon_g->{LX}/; }
										if ( $phon_g->{JA} ne "." ) { $aw =~ s/(JA=)\d+/$1$phon_g->{JA}/; }
										if ( $phon_g->{UH} ne "." ) { $aw =~ s/(UH=)\d+/$1$phon_g->{UH}/; }
										if ( $phon_g->{LH} ne "." ) { $aw =~ s/(LH=)\d+/$1$phon_g->{LH}/; }
										if ( $phon_g->{CL} ne "." ) { $aw =~ s/(CL=)\d+/$1$phon_g->{CL}/; }
										if ( $phon_g->{CA} ne "." ) { $aw =~ s/(CA=)\d+/$1$phon_g->{CA}/; }
										if ( $phon_g->{TL} ne "." ) { $aw =~ s/(TL=)\d+/$1$phon_g->{TL}/; }
										if ( $phon_g->{TA} ne "." ) { $aw =~ s/(TA=)\d+/$1$phon_g->{TA}/; }
										if ( $phon_g->{NA} ne "." ) { $aw =~ s/(NA=)\d+/$1$phon_g->{NA}/; }
										if ( $phon_g->{GW} ne "." ) { $aw =~ s/(JA=)\d+/$1$phon_g->{GW}/; }
										#print "    --aw=$aw--\n";

										# update articulator weights with any cluster-specific values
										if ( $seg_mod )	{
											if ( $mod_pars->{LX} ne "." ) { $aw =~ s/(LX=)\d+/$1$mod_pars->{LX}/; }
											if ( $mod_pars->{JA} ne "." ) { $aw =~ s/(JA=)\d+/$1$mod_pars->{JA}/; }
											if ( $mod_pars->{UH} ne "." ) { $aw =~ s/(UH=)\d+/$1$mod_pars->{UH}/; }
											if ( $mod_pars->{LH} ne "." ) { $aw =~ s/(LH=)\d+/$1$mod_pars->{LH}/; }
											if ( $mod_pars->{CL} ne "." ) { $aw =~ s/(CL=)\d+/$1$mod_pars->{CL}/; }
											if ( $mod_pars->{CA} ne "." ) { $aw =~ s/(CA=)\d+/$1$mod_pars->{CA}/; }
											if ( $mod_pars->{TL} ne "." ) { $aw =~ s/(TL=)\d+/$1$mod_pars->{TL}/; }
											if ( $mod_pars->{TA} ne "." ) { $aw =~ s/(TA=)\d+/$1$mod_pars->{TA}/; }
											if ( $mod_pars->{NA} ne "." ) { $aw =~ s/(NA=)\d+/$1$mod_pars->{NA}/; }
											if ( $mod_pars->{GW} ne "." ) { $aw =~ s/(JA=)\d+/$1$mod_pars->{GW}/; }
										}
										#print "    --aw=$aw--\n";

										# if vocalic, set all articulator weights = 1
										if ( $phon_g->{OSC} =~ /^v[^o]/ ) {
											$aw =~ s/(JA=)\d+/${1}1/;
											$aw =~ s/(CL=)\d+/${1}1/;
											$aw =~ s/(CA=)\d+/${1}1/;
										}
										$aw =~ s/,$//;
										$string .= " $aw";
										#print "    --string--$string--\n";

										# fetch phone-specific BLENDING VALUES, or use default values
										# if vocalic, set alpha = 1 regardless of entry in dictionary
										#print "    --osc=$phon_g->{OSC}--\n";
										if ( $phon_g->{OSC} =~ /^[v|v_rnd]$/ ) {
											#print "    --vowel-alpha=1--\n";
											$alpha = 1;
										}
										else {
											if ( $seg_mod )	{	$alpha = $mod_pars->{ALPH};	}
											else			{	$alpha = $phon_g->{ALPH};	}
											$alpha =~ s/\./$params->{ALPH}/;
											#print "    --alpha=$alpha--\n";
										}
										# beta = reciprocal of alpha (or 0)
										if ($alpha) { $beta = 1/$alpha	}
										else		{ $beta = $alpha	};
										$string_prt = $string." $alpha";
										$string .= " $alpha $beta";

										print "    $string_prt\n";
										(print FH_OUT "$string\n") or die "cannot write to $outfile: $!";

										if ($glottal{$tv})	{ $glottal_cnt++; }
									}
								}
								$last_seg = $seg;
								if ( ($seg eq "L") && ($onc eq "cod") ) {
									print "    (post-vocalic liquid treated as vocalic seg ".$seg_cnt." + cons seg ".++$seg_cnt.")\n";
								}

							}
							else {
								print "    no segment $seg found in arpabet\n";
							}

						}

					}
					else {
						print "    no $syllpart\n";
					}

				}
				$syll_tot++;
				$syll_cnt++;
				print "  \n";

			}
			print "  \n";
			(print FH_OUT "##\n\n") or die "cannot write to $outfile: $!";

		}

	}

close (FH_OUT);


#-------------------------------------------------------------------------
#-------------     functions and subroutines below      ------------------
#-------------------------------------------------------------------------
# useage: $y = parse_ARPA_str($x)
sub parse_ARPA_str {

	my $uc_str	 = shift;
	my $C	= "[B|P|M|D|T|N|B|G|K|V|F|S|Z|J|C|Y|W|R|L|H|Q]";
	my $F	= "[J|C|D|T|Z|S|H]";

	# parse ARPA string:
	$uc_str =~ /^([A-Z]*)([AEIUO][AEOWRYHX])([0-4]*)([A-Z]*)$/;
	my $nuc = $2;	 	# nucleus = 2 charaters before stress assignment
	my $ons = $1;	 	# onset   = all characters before nucleus
	my $cod = $4;	 	# coda    = all characters after stress assignment

	$ons =~ s/($C)/$1 /g;		# space-delineate consonants in cluster
	$ons =~ s/N G/NG/g;			# restore velar digraphs (NG)
	$ons =~ s/($F) H/$1H/g;		# restore fricative digraphs (_H)
	$ons =~ s/^ //;				# strip leading space
	$ons =~ s/ $//;				# strip trailing space

	$cod =~ s/($C)/$1 /g;		# space-delineate consonants in cluster
	$cod =~ s/N G/NG/g;			# restore velar digraphs (NG)
	$cod =~ s/($F) H/$1H/g;		# restore fricative digraphs (_H)
	$cod =~ s/^ //;				# strip leading space
	$cod =~ s/ $//;				# strip trailing space

	my $arpa_str = $ons."-".$nuc."_".$cod;
	return $arpa_str;

}

# useage: $y = parse_clust($x)
sub parse_clust {

	my $clust	= shift;

	# parse ARPA cluster:
	$clust	=~ /^($D|$C)( $D|$C)*$/;
	
	my $parsed = $1;
	if ($2 ne "") {
		$parsed .= " ".$2;
		$parsed =~ /^ ($D|$C)( $D|$C)*$/;
		if ($2 ne "") {
			$parsed .= " ".$2;
		}
	}
	$parsed =~ s/ ($D|$C)$//;
	return $parsed;

}
