use strict;
use warnings;

use Test::More;
plan tests => 2;

use XML::LibXML;

my $dom = XML::LibXML->load_xml( string => <<"XML" );
<dwimperl>
  <platform>linux</platform>
  <version number="5.18.1"></version>
</dwimperl>
XML

#is $dom->documentElement, 'dwimperl', 'root';
#diag explain $dom;

my @nodelist = $dom->getElementsByTagName('version');
#diag explain @nodelist;
is $nodelist[0]->getAttribute('number'), '5.18.1', 'getAttribute';

ok(1, 'done');
