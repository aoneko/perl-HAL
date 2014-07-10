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
        resources     => [],
        is_collection => 0,
        %$args,
    );
    my $self = bless $args => $class;
    $self->validate;
    return $self;
}

sub as_hashref {
    my $self = shift;

    my $instances = [];
    for (@{ $self->resources }) {
        push (@$instances, $_->as_hashref);
    }
    if (scalar(@$instances) == 1) {
        $instances = shift(@$instances);
    }

    my $ret = {};
    $ret->{ $self->name } = $instances;
}

sub validate {
    my $self = shift;
}

sub add_resources {
    my ($self, $hal) = @_;
    push (@{ $self->{resources} }, $hal);
}

1;
