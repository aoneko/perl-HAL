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
        "orders": {
            "_links": {
                "self": { "href": "/orders/123" },
                "basket": { "href": "/baskets/98712" },
                "customer": { "href": "/customers/7809" }
            },
            "total": 30,
            "currency": "USD",
            "status": "shipped"
        }
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

my $embedded_hal = $hal->embedded("orders");

is $embedded_hal->is_collection, 0;

note explain $embedded_hal->resources->as_hashref;

done_testing;
