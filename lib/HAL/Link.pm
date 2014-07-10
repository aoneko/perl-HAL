package HAL::Link;
use 5.008005;
use strict;
use warnings;

use Class::Accessor::Lite (
        new => 1,
        rw  => [qw/
            relation
            templated
            type
            deprecation
            name
            profile
            title
            hreflang
        /],
        ro  => [qw/
            resource
        /],
);

our $VERSION = "0.01";

sub as_hashref {
    my $self = shift;

    my $relation = $self->relation;
    my $link = {};
    $link->{$relation} = {
        href      => $self->href,
        ($self->templated)    ? (templated => $self->templated)     : (),
        ($self->type)         ? (type => $self->type)               : (),
        ($self->deprecation)  ? (deprecation => $self->deprecation) : (),
        ($self->name)         ? (name => $self->name) : (),
        ($self->profile)      ? (profile => $self->profile) : (),
        ($self->title)        ? (title => $self->title) : (),
        ($self->hreflang)     ? (hreflang => $self->hreflang) : (),
    };

    return $link;
}

sub href {
    my $self = shift;
    return $self->{href}; #TODO
}

1;
