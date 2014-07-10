use strict;
use warnings;

use Test::More;
use JSON;
use HAL;

my $doc_json = <<'EOT'
{
    "_links": {
        "self": { "href": "/orders" },
        "next": { "href": "/orders?page=2" },
        "find": { "href": "/orders{?id}", "templated": true }
    },
    "_embedded": {
        "orders": [{
            "_links": {
                "self": { "href": "/orders/123" },
                "basket": { "href": "/baskets/98712" },
                "customer": { "href": "/customers/7809" }
            },
            "total": 30,
            "currency": "USD",
            "status": "shipped"
        },{
            "_links": {
                "self": { "href": "/orders/124" },
                "basket": { "href": "/baskets/97213" },
                "customer": { "href": "/customers/12369" }
            },
           "total": 20,
           "currency": "USD",
           "status": "processing"
        }]
    },
    "currentlyProcessing": 14,
    "shippedToday": 20
}
EOT
;

my $hal = HAL->from_hash( decode_json($doc_json) );

is_deeply $hal->resource, {
    currentlyProcessing => 14,
    shippedToday => 20,
};

is scalar(@ {$hal->links}), 3; #TODO

my $embedded_hal = $hal->embedded("orders");
for my $order ( @ { $embedded_hal->resources} ) {
    note explain $order->resource;
    note explain $order->links->[0];
}

done_testing;
