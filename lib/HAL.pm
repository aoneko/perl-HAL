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
        links         => {},
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

    if ($self->links) {
        my $links = {};
        for (keys %{ $self->{links} }) {
            $links = {
                %$links,
                %{ $self->{links}->{$_}->as_hashref },
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
    else { #FIXME
        $document->{_embedded} = {};
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

            my $embedded_hal = $hal->add_embedded($property, +{
                is_collection => $is_collection,
            });
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

    for my $rel (keys %$links) {

        my $instance = HAL::Link->new({
            relation => $rel,
            resource => $self->resource,
        });

        my $entities = (ref($links->{$rel}) eq 'HASH') ? [$links->{$rel}] : $links->{$rel};

        for my $entity (@$entities) {
            $instance->add_link(+{
                href        => $entity->{href},
                templated   => $entity->{templated},
                type        => $entity->{type},
                deprecation => $entity->{deprecation},
                name        => $entity->{name},
                profile     => $entity->{profile},
                title       => $entity->{title},
                hreflang    => $entity->{hreflang},
            });
        }

        $self->{links}->{$rel} = $instance;
    }
}

sub add_embedded {
    my ($self, $property, $opts) = @_;

    $opts ||= +{};
    my $instance = HAL::Embedded->new({
        name => $property,
        ($opts->{is_collection}) ? (resources => []) : (),
    });

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

