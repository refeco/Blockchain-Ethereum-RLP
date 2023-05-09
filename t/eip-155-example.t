#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Blockchain::Ethereum::RLP::Encoder;

subtest "eip-155 example test" => sub {
    my $rlp = Blockchain::Ethereum::RLP::Encoder->new();
    my $encoded =
        $rlp->encode(['0x9', '0x4A817C800', '0x5208', '0x3535353535353535353535353535353535353535', '0xDE0B6B3A7640000', '0x', '0x1', '0x', '0x']);
    is($encoded, 'ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080');
};

done_testing;

