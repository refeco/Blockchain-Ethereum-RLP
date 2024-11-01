# NAME

Blockchain::Ethereum::RLP - Ethereum RLP encoding/decoding utility

# VERSION

version 0.011

# SYNOPSIS

Allow RLP encoding and decoding

```perl
my $rlp = Blockchain::Ethereum::RLP->new();

my $tx_params  = ['0x9', '0x4a817c800', '0x5208', '0x3535353535353535353535353535353535353535', '0xde0b6b3a7640000', '0x', '0x1', '0x', '0x'];
my $encoded = $rlp->encode($params); #ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080

my $encoded_tx_params = 'ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080';
my $decoded = $rlp->decode(pack "H*", $encoded_tx_params); #['0x9', '0x4a817c800', '0x5208', '0x3535353535353535353535353535353535353535', '0xde0b6b3a7640000', '0x', '0x1', '0x', '0x']
```

# METHODS

## encode

Encodes the given input to RLP

- `$input` hexadecimal string or reference to an hexadecimal string array

Return the encoded bytes

## decode

Decode the given input from RLP to the specific return type

- `$input` RLP encoded bytes

Returns an hexadecimals string or an array reference in case of multiple items

# AUTHOR

Reginaldo Costa <refeco@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

```
The MIT (X11) License
```
