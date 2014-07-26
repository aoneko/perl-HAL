use strict;
use warnings;

use Test::More;

use HAL;
use HAL::Embedded;

subtest "new" => sub {
    my $embedded = HAL::Embedded->new;
    my $hal  = +{ a => 1 };
    my $hal2 = +{ b => 1 };

    $embedded->add_resources($hal);
    note explain $embedded->resources;
    $embedded->add_resources($hal2);
    note explain $embedded->resources;
    is_deeply $embedded->resources, [$hal, $hal2];
};

done_testing;
