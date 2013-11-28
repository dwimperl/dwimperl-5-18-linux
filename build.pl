#!/usr/bin/perl
use strict;
use warnings;


use Net::SSH qw(ssh);
system 'scp bootstrap.sh root@s13:';
ssh('root@s13', "./bootstrap.sh");
