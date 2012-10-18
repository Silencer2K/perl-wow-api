package WoW::Armory::Class;

use strict;
use warnings;

use base 'Class::Accessor';

use constant FIELDS => [];
use constant BLESSED_FIELDS => {};
use constant LIST_FIELDS => {};

sub new {
    my ($proto, $fields) = @_;

    my $class = ref $proto || $proto;
    my $self = $class->SUPER::new($fields);

    for my $field (keys %$self) {
        next if !defined $self->{$field};
        if ($class->BLESSED_FIELDS()->{$field}) {
            $self->{$field} = $class->BLESSED_FIELDS()->{$field}->new($self->{$field});
        }
        elsif ($class->LIST_FIELDS()->{$field}) {
            $_ = $class->LIST_FIELDS()->{$field}->new($_) for @{$self->{$field}};
        }
    }

    return $self;
}

sub mk_accessors {
    my ($proto, @fields) = @_;

    my $class = ref $proto || $proto;

    $class->SUPER::mk_accessors(
        @fields,
        @{$class->FIELDS()},
        keys %{$class->BLESSED_FIELDS()},
        keys %{$class->LIST_FIELDS()}
    );
}

__PACKAGE__->mk_accessors;

1;
