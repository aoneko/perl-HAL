use strict;
use warnings;

use Test::More;
use HAL::Link;

subtest "new" => sub {
    my $link = HAL::Link->new(+{
        relation  => 'self',
        href      => '/orders',
        templated => 0,
    });
    note explain $link;

    is $link->relation, 'self';
};

done_testing;
