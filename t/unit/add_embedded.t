use strict;
use warnings;

use Test::More;
use HAL;

subtest "new" => sub {
    my $hal = HAL->new;
    $hal->add_embedded('order');

    is ref( $hal->embedded('order') ), 'HAL::Embedded';
};

done_testing;
