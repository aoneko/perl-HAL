use strict;
use warnings;

use Test::More;
use HAL::Link;

subtest "as_hashref" => sub {
    my $link = HAL::Link->new(+{
        relation  => 'self',
    });

    $link->add_link(+{
        href      => '/orders',
        type      => 'text/html',
        templated => 0,
    });

    is_deeply $link->as_hashref, +{
        self => {
            href => "/orders",
            type => "text/html"
        },
    };

    note explain $link->as_hashref;

    $link->add_link(+{
        href      => '/orders?format=json',
        type      => 'application/json',
        templated => 0,
    });

    is_deeply $link->as_hashref, +{
        self => [
            +{
                href => "/orders",
                type => "text/html"
            },
            +{
                href => "/orders?format=json",
                type => 'application/json',
            },
        ]
    };

    note explain $link->as_hashref;
};

done_testing;
