#!/usr/bin/perl
use strict;
use warnings;


my $start_time = time;
use Net::SSH qw(ssh);
system 'scp bootstrap.sh root@s13:';
system 'scp README.txt root@s13:';
system 'scp empty.pod root@s13:';
system 'scp -r t/ root@s13:';
ssh('root@s13', "./bootstrap.sh");

my $end_time = time;
printf "Elapsed time: %s\n", ($end_time - $start_time)
