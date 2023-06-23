package Blockchain::Ethereum::RLP;

use v5.26;
use strict;
use warnings;

use Carp;

use constant {
    STRING => 'str',
    LIST   => 'list'
};

sub new {
    return bless {}, shift;
}

sub encode {
    my ($self, $input) = @_;

    if (ref $input eq 'ARRAY') {
        my $output = '';
        $output .= $self->encode($_) for $input->@*;

        return $self->_encode_length(length($output), 192) . $output;
    }

    $input =~ s/^0x//g;

    # zero will be considered empty as per RLP specification
    if ($input eq '0' || $input eq '' || $input eq '0x') {
        $input = chr(0x80);
        return $input;
    }

    # pack will add a null character at the end if the length is odd
    # RLP expects this to be added at the left instead.
    $input = "0$input" if length($input) % 2 != 0;
    $input = pack("H*", $input);

    my $input_length = length $input;

    return $input if $input_length == 1 && ord $input <= 127;
    return $self->_encode_length($input_length, 128) . $input;
}

sub _encode_length {
    my ($self, $length, $offset) = @_;

    return chr($length + $offset) if $length <= 55;

    if ($length < 256**8) {
        my $bl = $self->_to_binary($length);
        return chr(length($bl) + $offset + 55) . $bl;
    }

    croak "Input too long";
}

sub _to_binary {
    my ($self, $x) = @_;
    return '' if $x == 0;
    return $self->_to_binary(int($x / 256)) . chr($x % 256);
}

sub decode {
    my ($self, $input) = @_;

    return [] unless length $input;

    my ($offset, $data_length, $type) = $self->_decode_length($input);

    if ($type eq STRING) {
        my $hex = unpack("H*", substr($input, $offset, $data_length));
        # same as for the encoding we do expect an prefixed 0 for
        # odd length hexadecimal values, this just removes the 0 prefix.
        $hex = substr($hex, 1) if $hex =~ /^0/ && (length($hex) - 1) % 2 != 0;
        return '0x' . $hex;
    }

    my @output;
    my $list_data   = substr($input, $offset, $data_length);
    my $list_offset = 0;
    # recursive arrays
    while ($list_offset < length($list_data)) {
        my ($item_offset, $item_length, $item_type) = $self->_decode_length(substr($list_data, $list_offset));
        my $list_item = $self->decode(substr($list_data, $list_offset, $item_offset + $item_length));
        push @output, $list_item;
        $list_offset += $item_offset + $item_length;
    }

    return \@output;
}

sub _decode_length {
    my ($self, $input) = @_;

    my $length = length($input);
    croak "Invalid empty input" unless $length;

    my $prefix = ord(substr($input, 0, 1));

    if ($prefix <= 127) {
        # single byte
        return (0, 1, STRING);
    } elsif ($prefix <= 183 && $length > $prefix - 128) {
        # short string
        my $str_length = $prefix - 128;
        return (1, $str_length, STRING);
    } elsif ($prefix <= 191 && $length > $prefix - 183 && $length > $prefix - 183 + $self->_to_integer(substr($input, 1, $prefix - 183))) {
        # long string
        my $str_prefix_length = $prefix - 183;
        my $str_length        = $self->_to_integer(substr($input, 1, $str_prefix_length));
        return (1 + $str_prefix_length, $str_length, STRING);
    } elsif ($prefix <= 247 && $length > $prefix - 192) {
        # list
        my $list_length = $prefix - 192;
        return (1, $list_length, LIST);
    } elsif ($prefix <= 255 && $length > $prefix - 247 && $length > $prefix - 247 + $self->_to_integer(substr($input, 1, $prefix - 247))) {
        # long list
        my $list_prefix_length = $prefix - 247;
        my $list_length        = $self->_to_integer(substr($input, 1, $list_prefix_length));
        return (1 + $list_prefix_length, $list_length, LIST);
    }

    croak "Invalid RLP input";
}

sub _to_integer {
    my ($self, $b) = @_;

    my $length = length($b);
    croak "Invalid empty input" unless $length;

    return ord($b) if $length == 1;

    return ord(substr($b, -1)) + $self->_to_integer(substr($b, 0, -1)) * 256;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::RLP - Ethereum RLP encoding/decoding utility

=head1 VERSION

Version 0.003

=cut

our $VERSION = '0.003';

=head1 SYNOPSIS

Allow RLP encoding and decoding

    my $rlp = Blockchain::Ethereum::RLP->new();

    my $tx_params  = ['0x9', '0x4a817c800', '0x5208', '0x3535353535353535353535353535353535353535', '0xde0b6b3a7640000', '0x', '0x1', '0x', '0x'];
    my $encoded = $rlp->encode($params); #ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080

    my $encoded_tx_params = 'ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080';
    my $decoded = $rlp->decode(pack "H*", $encoded_tx_params); #['0x9', '0x4a817c800', '0x5208', '0x3535353535353535353535353535353535353535', '0xde0b6b3a7640000', '0x', '0x1', '0x', '0x']
    ...

=head1 METHODS

=head2 encode

Encodes the given input to RLP

Usage:

    encode(hex string /  hex array reference) ->  encoded bytes

=over 4

=item * C<$input> hexadecimal string or reference to an hexadecimal string array

=back

Return the encoded bytes

=cut

=head2 decode

Decode the given input from RLP to the specific return type

Usage:

    decode(RLP encoded bytes) -> hexadecimal string / array reference

=over 4

=item * C<$input> RLP encoded bytes

=back

Returns an hexadecimals string or an array reference in case of multiple items

=cut

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-RPL>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::RLP

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
