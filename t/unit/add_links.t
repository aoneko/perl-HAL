use strict;
use warnings;

use Test::More;
use HAL;

subtest "add_links" => sub {
    my $hal = HAL->new;
    $hal->add_links(
       self => { href => "/orders" },
       next => { href => "/orders?page=2" },
       find => { href => "/orders{?id}", templated => 1 },
    );

    note explain $hal->links;
    ok 1;
};

done_testing;
