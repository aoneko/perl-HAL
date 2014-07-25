use strict;
use warnings;

use Test::More;
use JSON;
use HAL;

my $expected = <<'EOT'
{
    "_links": {
        "self": [{ "href": "/orders" }, { "href": "/orders?format=json"}],
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

my $hal = HAL->new;
$hal->add_resource({
    currentlyProcessing => 14,
    shippedToday => 20,
});

$hal->add_links(
    self => { href => "/orders" },
    next => { href => "/orders?page=2" },
    find => { href => "/orders{?id}", templated => JSON::true },
);

note explain $hal->links;

$hal->links->{self}->add_link({
    href => "/orders?format=json"
});

my $orders = $hal->add_embedded("orders");

my $order1 = HAL->new;
$order1->add_resource({
    total => 30,
    currency => "USD",
    status => "shipped",
});
$order1->add_links(
    self     => { href => "/orders/123" },
    basket   => { href => "/baskets/98712" },
    customer => { href => "/customers/7809" },
);

my $order2 = HAL->new;
$order2->add_resource({
    total => 20,
    currency => "USD",
    status => "processing",
});
$order2->add_links(
    self     => { href => "/orders/124" },
    basket   => { href => "/baskets/97213" },
    customer => { href => "/customers/12369" },
);

$orders->add_resources($order1);
$orders->add_resources($order2);

note explain decode_json($hal->as_json);
is_deeply( decode_json($hal->as_json), decode_json($expected) );

done_testing;
