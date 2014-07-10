package HAL;
use 5.008005;
use strict;
use warnings;

use HAL::Link;
use HAL::Embedded;
use Class::Accessor::Lite (
        new => 0,
        rw  => [qw/
        /],
        ro  => [qw/
            resource
            links
        /],
);
use Clone qw/clone/;
use JSON;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        resource      => {},
        links         => [],
        embedded      => {},
        %$args,
    );
    my $self = bless $args => $class;
    $self->validate;
    return $self;
}

sub as_hashref {
    my $self = shift;

    my $document = {
        %{ $self->{resource} },
    };

    if (scalar (@{ $self->links })) {
        my $links = {};
        for (@{ $self->{links} }) {
            $links = {
                %$links,
                %{ $_->as_hashref },
            };
        }
        $document->{_links} = $links;
    }

    if (%{ $self->embedded} ) {
        my $embedded = {};
        for my $name (keys %{ $self->embedded }) {
            $embedded->{$name} = $self->embedded($name)->as_hashref;
        }
        $document->{_embedded} = $embedded;
    }

    return $document;
}

sub as_json {
    my $self = shift;
    return encode_json($self->as_hashref);
}

sub from_hash {
    my $self = shift;

    my $document = ref $_[0] ? $_[0] : { @_ };

    my $cloned = clone $document;
    my $links    = delete $cloned->{_links};
    my $embedded = delete $cloned->{_embedded};

    my $hal = HAL->new;
    $hal->add_resource($cloned);

    if ($links) {
        $hal->add_links($links);
    }
    if ($embedded) {
        for my $property (keys %$embedded) {

            my $is_collection = (ref ($embedded->{$property}) eq 'ARRAY') ? 1 : 0;
            my $instances = ($is_collection) ? ($embedded->{$property}) : [($embedded->{$property})];

            my $embedded_hal = $hal->add_embedded($property);
            for (@$instances) {
                my $hal = HAL->new;
                my $links = delete $_->{_links};
                $hal->add_resource($_);
                $hal->add_links($links);
                $embedded_hal->add_resources($hal);
            }
        }
    }

    return $hal;
}

sub validate {
    my $self = shift;
}

sub add_resource {
    my $self = shift;
    my $resource = ref $_[0] ? $_[0] : { @_ };

    $self->{resource} = $resource;
}

sub add_links {
    my $self = shift;
    my $links = ref $_[0] ? $_[0] : { @_ };

    #validate
    for my $rel (keys %$links) { #TODO ikann...
        my $instance = HAL::Link->new({
            relation    => $rel,
            href        => $links->{$rel}->{href}, #fukusuu aruyo
            templated   => $links->{$rel}->{templated}, #json true tekina
            type        => $links->{$rel}->{type},
            deprecation => $links->{$rel}->{deprecation},
            name        => $links->{$rel}->{name},
            profile     => $links->{$rel}->{profile},
            title       => $links->{$rel}->{title},
            hreflang    => $links->{$rel}->{hreflang},
            resource    => $self->resource, #TODO weaken?
        });
        push (@{ $self->{links} }, $instance);
    }
}

sub add_embedded {
    my ($self, $property) = @_;

    my $instance = HAL::Embedded->new(name => $property);

    $self->{embedded}->{$property} = $instance;
    return $instance;
}

sub embedded {
    my ($self, $property) = @_;

    return ($property) ? $self->{embedded}->{$property} : $self->{embedded};
}

1;
__END__

=encoding utf-8

=head1 NAME

HAL - It's new $module

=head1 SYNOPSIS

    use HAL;

=head1 DESCRIPTION

HAL is ...

=head1 LICENSE

Copyright (C) aoneko.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

aoneko E<lt>aoneko@cpan.orgE<gt>

=cut

