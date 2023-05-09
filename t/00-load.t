#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Blockchain::Ethereum::RLP' ) || print "Bail out!\n";
}

diag( "Testing Blockchain::Ethereum::RLP $Blockchain::Ethereum::RLP::VERSION, Perl $], $^X" );
