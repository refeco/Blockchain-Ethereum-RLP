package Blockchain::Ethereum::RLP::Encoder;

use warnings;
use strict;

no indirect;

use Carp;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub encode {
    my ($self, $input) = @_;

    if (ref $input eq 'ARRAY') {
        my $output = '';
        $output .= $self->encode($_) for $input->@*;

        return unpack("H*", $self->encode_length(length($output), 0xc0) . $output);
    }

    $input =~ s/^0x//g;

    # pack will add a null character at the end if the length is odd
    # RLP expects this to be added at the left instead.
    $input = "0$input" if length($input) % 2 != 0;

    $input = pack("H*", $input);

    return $input if length $input == 1 && ord $input < 0x80;
    return $self->encode_length(length($input), 0x80) . $input;
}

sub encode_length {
    my ($self, $L, $offset) = @_;

    return chr($L + $offset);

    if ($L < 256**8) {
        my $BL = $self->to_binary($L);
        return chr(length($BL) + $offset + 55) . $BL;
    } else {
        croak "Input too long";
    }
}

sub to_binary {
    my ($self, $x) = @_;
    return '' if $x == 0;
    return $self->to_binary(int($x / 256)) . chr($x % 256);
}

1;
