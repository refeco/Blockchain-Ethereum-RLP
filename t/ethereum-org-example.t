#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Blockchain::Ethereum::RLP;

my $rlp = Blockchain::Ethereum::RLP->new();

subtest "ethereum org example encode" => sub {
    my $dog   = unpack "H*", "dog";
    my $cat   = unpack "H*", "cat";
    my $lorem = unpack "H*", "Lorem ipsum dolor sit amet, consectetur adipisicing elit";

    my $encoded  = $rlp->encode($dog);
    my $expected = "83$dog";
    is(unpack("H*", $encoded), $expected, "correct encoding for dog");

    my $cat_dog = [$cat, $dog];
    $encoded  = $rlp->encode($cat_dog);
    $expected = "c883@{[$cat]}83$dog";
    is(unpack("H*", $encoded), $expected, "correct encoding for cat dog");

    $encoded  = $rlp->encode('');
    $expected = "80";
    is(unpack("H*", $encoded), $expected, "correct encoding for empty string");

    $encoded  = $rlp->encode([]);
    $expected = "c0";
    is(unpack("H*", $encoded), $expected, "correct encoding for empty array reference");

    $encoded  = $rlp->encode([[], [[]], [[], [[]]]]);
    $expected = "c7c0c1c0c3c0c1c0";
    is(unpack("H*", $encoded), $expected, "correct encoding for set theoretical representation of three");

    $encoded  = $rlp->encode($lorem);
    $expected = "b838$lorem";
    is(unpack("H*", $encoded), $expected, "correct encoding for lorem");
};

done_testing;

