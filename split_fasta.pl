#!/usr/bin/perl -w 

use strict;
use Getopt::Long;

my $help = 0;
my $sp = 5;
my @a = ();
GetOptions (
	"s=i" => \$sp,
	"h!"  => \$help
);

my $msg ="
         ======================================== Help instruction ========================================
Usage :    
        split_fasta/pl [option] [fasta file]

[-sp]      split into ? fasta file. default = 5.
[-h]       Show this help message.


feel free to use it!
";

($help)? do {print "$msg\n"; exit} : ();

# open fasta file 

open IN, "<$ARGV[0]" or die "can't open fasta file!\n$!\n";

my $id = <IN>; chomp $id;
my $seq;
my $otu_count = 1;

### initialize array
foreach(1..$sp){
	push(@a, "");
}

while (<IN>) {
	chomp;
	if ($_ =~ /^>/) {
		$a[$otu_count % $sp] .= "$id\n$seq\n";
		#my $i;
		#for ($i=0; $i<$sp; $i++) {
		#	if ($q == $i) {
		#	}
		#}
		$id = $_;
		$seq = "";
		$otu_count ++;
	} else {
		$seq .= $_;
	}
}
$a[$otu_count % $sp] .=  "$id\n$seq\n";


close IN;

#print "$a[0]";
foreach my $e (0..$#a) {
	open OUT, ">sp$e.fa";
	print OUT "$a[$e]";
	close OUT;
}




