package HAL::Link;
use 5.008005;
use strict;
use warnings;

use Class::Accessor::Lite (
        new => 0,
        rw  => [qw/
            relation
            entities
        /],
        ro  => [qw/
            resource
        /],
);

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        relation      => '',
        entities      => [],
        resource      => {},
        %$args,
    );
    my $self = bless $args => $class;
    return $self;
}

sub add_link {
    my $self = shift;
    my $entity = ref $_[0] ? $_[0] : { @_ };

    push (@{ $self->{entities} }, +{
        href      => $entity->{href},
        ($entity->{templated})   ? (templated    => $entity->{templated})   : (),
        ($entity->{type})        ? (type         => $entity->{type})        : (),
        ($entity->{deprecation}) ? (deprecation  => $entity->{deprecation}) : (),
        ($entity->{name})        ? (name         => $entity->{name})        : (),
        ($entity->{profile})     ? (profile      => $entity->{profile})     : (),
        ($entity->{title})       ? (title        => $entity->{title})       : (),
        ($entity->{hreflang})    ? (hreflang     => $entity->{hreflang})    : (),
    });

}

sub as_hashref {
    my $self = shift;

    my $relation = $self->relation;
    my $link = {};
    $link->{$relation} = (scalar(@{ $self->{entities} }) == 1) ? $self->{entities}->[0] : $self->{entities};

    return $link;
}

1;
