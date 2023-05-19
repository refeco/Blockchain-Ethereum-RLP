package Blockchain::Ethereum::RLP;

use v5.26;
use strict;
use warnings;
no indirect;

use Carp;

use constant {
    STRING => 'str',
    LIST => 'list'
};

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

        return $self->_encode_length(length($output), 0xc0) . $output;
    }

    $input =~ s/^0x//g;

    # pack will add a null character at the end if the length is odd
    # RLP expects this to be added at the left instead.
    $input = "0$input" if length($input) % 2 != 0;

    $input = pack("H*", $input);

    return $input if length $input == 1 && ord $input < 0x80;
    return $self->_encode_length(length($input), 0x80) . $input;
}

sub _encode_length {
    my ($self, $L, $offset) = @_;

    return chr($L + $offset) if $L < 56;

    if ($L < 256**8) {
        my $BL = $self->_to_binary($L);
        return chr(length($BL) + $offset + 55) . $BL;
    } else {
        croak "Input too long";
    }
}

sub _to_binary {
    my ($self, $x) = @_;
    return '' if $x == 0;
    return $self->_to_binary(int($x / 256)) . chr($x % 256);
}


sub decode {
    my ($self, $input) = @_;

    if (length($input) == 0) {
        return [];
    }

    my @output;
    my ($offset, $dataLen, $type) = $self->_decode_length($input);

    if ($type eq 'str') {
        my $hex = unpack( "H*", substr($input, $offset, $dataLen));
        $hex =~ s/^0+//g;
        push @output, '0x'. $hex;
    } elsif ($type eq 'list') {
        push @output, @{$self->_instantiate_list(substr($input, $offset, $dataLen))};
    }

    push @output, @{$self->decode(substr($input, $offset + $dataLen))};

    return \@output;
}

sub _decode_length {
    my ($self, $input) = @_;

    my $length = length($input);
    if ($length == 0) {
        die "Input is null";
    }

    my $prefix = ord(substr($input, 0, 1));

    if ($prefix <= 0x7f) {
        return (0, 1, 'str');
    } elsif ($prefix <= 0xb7 && $length > $prefix - 0x80) {
        my $strLen = $prefix - 0x80;
        return (1, $strLen, 'str');
    } elsif ($prefix <= 0xbf && $length > $prefix - 0xb7 && $length > $prefix - 0xb7 + $self->_to_integer(substr($input, 1, $prefix - 0xb7))) {
        my $lenOfStrLen = $prefix - 0xb7;
        my $strLen      = $self->_to_integer(substr($input, 1, $lenOfStrLen));
        return (1 + $lenOfStrLen, $strLen, 'str');
    } elsif ($prefix <= 0xf7 && $length > $prefix - 0xc0) {
        my $listLen = $prefix - 0xc0;
        return (1, $listLen, 'list');
    } elsif ($prefix <= 0xff && $length > $prefix - 0xf7 && $length > $prefix - 0xf7 + $self->_to_integer(substr($input, 1, $prefix - 0xf7))) {
        my $lenOfListLen = $prefix - 0xf7;
        my $listLen      = $self->_to_integer(substr($input, 1, $lenOfListLen));
        return (1 + $lenOfListLen, $listLen, 'list');
    }

    die "Input does not conform to RLP encoding form";
}

sub _to_integer {
    my ($self, $b) = @_;

    my $length = length($b);
    if ($length == 0) {
        die "Input is null";
    } elsif ($length == 1) {
        return ord($b);
    }

    return ord(substr($b, -1)) + $self->_to_integer(substr($b, 0, -1)) * 256;
}

sub _instantiate_list {
    my ($self, $list) = @_;

    my $rlp_decoded = $self->decode($list);
    my @decoded_values;
    foreach my $item (@$rlp_decoded) {
        push @decoded_values, $item;
    }

    return \@decoded_values;
}

=head1 NAME

Blockchain::Ethereum::RLP - The great new Blockchain::Ethereum::RLP!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Blockchain::Ethereum::RLP;

    my $foo = Blockchain::Ethereum::RLP->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-blockchain-ethereum-rlp at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Blockchain-Ethereum-RLP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::RLP


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Blockchain-Ethereum-RLP>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Blockchain-Ethereum-RLP>

=item * Search CPAN

L<https://metacpan.org/release/Blockchain-Ethereum-RLP>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by Reginaldo Costa.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Blockchain::Ethereum::RLP
