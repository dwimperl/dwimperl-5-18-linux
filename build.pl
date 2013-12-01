#!/usr/bin/perl
use strict;
use warnings;

my $options = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
my $remote = 'root@s13';

my $start_time = time;
foreach my $src ('bootstrap.sh', 'README.txt', 'empty.pod', 't/' ) {
	system "scp -q $options -r $src $remote:";
}
system "ssh -q $options $remote ./bootstrap.sh";
my $end_time = time;
printf "Elapsed time: %s\n", ($end_time - $start_time)

