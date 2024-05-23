#!/usr/bin/perl -w 

use strict;
use Getopt::Long;
use threads;
use experimental qw(signatures);    # disable complex warning 

# set parameter 
my $thread = 2;
my $help = 0;
my $out = "lowconf.megablast";
GetOptions(
    "t=s" => \$thread,
    "o=s" => \$out,
    "h!"  => \$help
);

my $msg = "
Welcome to the -help

Usage :    
        Parallelmegablast.pl [option] [fasta file]

[-t]       Thread (CPU), default = 2.
[-o]       Output file name, default = zotus.rdp
[-h]       Show this help message.


feel free to use it!
";
# show help message
$help? do {print "$msg\n"; exit;} : ();

# split fasta file 
system "split_fasta.pl -s $thread $ARGV[0]";
print "split complete!\n";

# run RDP Classifier in parallel (using thread)
my @tids;
foreach my $e (0..$thread-1) {
	my $tid = threads->create(\&mega_blast, "sp$e.fa", "blast_out$e");
	push(@tids, $tid);
	sleep (10);
}

### join each threads ++  paxon non blocking join
my $thread_cnt = scalar(@tids);  # count how many thread you use 
while ($thread_cnt) {
	# only join those threads that are joinable
	my @threads = threads->list(threads::joinable); 
	
	# find finished thread
	foreach my $tid (@threads){
		my $ret = $tid->join();
		print "Thread ". $tid->tid(). " joined: ". ($ret? "failed" : "success");
		print "\n";
		$thread_cnt--;
	}
	sleep(20);
	my $re = qq(find . -type f -name 'blast_out*' -exec sh -c 'echo -n "{} "; grep "Query= Zotu" "{}" | wc -l' \\;);
	system ($re);
	# print "\tRemaining threads: $thread_cnt\n";
}


### cat results
my $cmd = "cat " . join(" ", map("blast_out$_", (0..$thread-1))) . " > $out";
system "$cmd";
print "Complete!\nRemoving Intermediate...\n";
system "rm sp\*.fa";
system "rm blast_out\*";
print "Intermediate files removed";


### Sub ### 
sub mega_blast ($in, $sout) {
	print "my_web_blast.pl megablast nt $in > $sout\n";
	system "my_web_blast.pl megablast nt $in > $sout";
	return 0;	
}

