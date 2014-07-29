package HAL::Embedded;
use 5.008005;
use strict;
use warnings;

use Class::Accessor::Lite (
        new => 0,
        rw  => [qw/
        /],
        ro  => [qw/
            name
            resources
        /],
);

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        name          => '',
        %$args,
    );
    my $self = bless $args => $class;
    $self->validate;
    return $self;
}

sub as_hashref {
    my $self = shift;

    my $instances = [];

    if ( ref($self->{resources}) && ref($self->{resources}) eq 'ARRAY' ) {
        for (@{ $self->resources }) {
            push (@$instances, $_->as_hashref);
        }
    }
    else {
        $instances = $self->resources->as_hashref;
    }
    my $ret = {};
    $ret->{ $self->name } = $instances;
}

sub validate {
    my $self = shift;
}

sub add_resources {
    my ($self, $hal) = @_;

    if ( ref($self->{resources}) && ref($self->{resources}) eq 'ARRAY' ) {
        push (@{ $self->{resources} }, $hal);
    }
    elsif ( !ref($self->{resources}) ) {
        $self->{resources} = $hal;
    }
    else {
        $self->{resources} = [$self->{resources}, $hal];
    }
}

sub is_collection {
    my $self = shift;
    return ( ref($self->{resources}) && ref($self->{resources}) eq 'ARRAY' ) ? 1 : 0;
}

1;
