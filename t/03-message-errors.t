#!/usr/bin/perl -w
use strict;
use Test::More tests => 24;
use t::Helpers qw/test_warn test_error/;

use_ok("xPL::Message");

my $msg;
is(test_error(sub { $msg = xPL::Message->new(); }),
   "xPL::Message->new: requires 'class' parameter",
   "xPL::Message missing class test");

is(test_error(sub { $msg = xPL::Message->new(class => "fred.schema") }),
   "xPL::Message->new: requires 'message_type' parameter",
   "xPL::Message missing message type test");

is(test_error(sub { $msg = xPL::Message->new(class => 'fred') }),
   "xPL::Message->new: requires 'class_type' parameter",
   "xPL::Message missing class type test");

is(test_error(sub { $msg = xPL::Message->new(class => 'thisistoolong',
                                             class_type => 'test') }),
   "xPL::Message->new: 'class' parameter is invalid.
It must be 8 characters from A-Z, a-z and 0-9.",
   "xPL::Message invalid class test");

is(test_error(sub { $msg = xPL::Message->new(class => 'fred',
                                             class_type => 'thisistoolong') }),
   "xPL::Message->new: 'class_type' parameter is invalid.
It must be 8 characters from A-Z, a-z and 0-9.",
   "xPL::Message invalid class type test");

is(test_error(sub { $msg = xPL::Message->new(class => "fred.schema",
                                             message_type => 'testing') }),
   "xPL::Message->message_type: ".
   "message type identifier, testing, is invalid.
It should be one of XPL-CMND, XPL-STAT or XPL-TRIG.",
   "xPL::Message invalid message type test");

is(test_error(sub { $msg = xPL::Message->new(message_type => "xpl-stat",
                                             class => "fred.schema"); }),
   "xPL::Message->parse_head_parameters: requires 'source' parameter",
   "xPL::Message missing source test");

is(test_error(sub { $msg = xPL::Message->new(message_type => "xpl-stat",
                                             head =>
                                             {
                                              source => 'source',
                                             },
                                             class => "fred.schema",
                                            ); }),
   "xPL::Message->source: source, source, is invalid.
Invalid format - should be 'vendor-device.instance'.",
   "xPL::Message invalid source format test");

is(test_error(sub { $msg =
                      xPL::Message->new(message_type => "xpl-stat",
                                        head =>
                                        {
                                         source => "vendortoolong-device.id",
                                        },
                                        class => "fred.schema",
                                       ); }),
   "xPL::Message->source: source, vendortoolong-device.id, is invalid.
Invalid vendor id - maximum of 8 chars from A-Z, a-z, and 0-9.",
   "xPL::Message invalid source vendor too long test");

is(test_error(sub { $msg =
                      xPL::Message->new(message_type => "xpl-stat",
                                        head =>
                                        {
                                         source => "vendor-devicetoolong.id",
                                        },
                                        class => "fred.schema",
                                       ); }),
   "xPL::Message->source: source, vendor-devicetoolong.id, is invalid.
Invalid device id - maximum of 8 chars from A-Z, a-z, and 0-9.",
   "xPL::Message invalid source device test");

is(test_error(sub { $msg =
                      xPL::Message->new(message_type => "xpl-stat",
                                        head =>
                                        {
                                         source =>
                                           "vendor-device.thisinstancetoolong",
                                        },
                                        class => "fred.schema",
                                       ); }),
   "xPL::Message->source: ".
   "source, vendor-device.thisinstancetoolong, is invalid.
Invalid instance id - maximum of 16 chars from A-Z, a-z, and 0-9.",
   "xPL::Message invalid source instance test");


my $payload =
"xpl-stat
{
hop=1
source=vendor-device-instance
target=*
}
fred.schema
{
param1=value1
}
";

my $str = xPL::Message->new_from_payload($payload)->string;
is($str, $payload, "payload test");

is(test_warn(sub { $msg =
                     xPL::Message->new_from_payload($payload.
                                                    "some-trailing-junk"); }),
   "xPL::Message->new_from_payload: Trailing trash: some-trailing-junk",
   "trailing junk warning");

chomp($payload);
is(test_warn(sub { $msg = xPL::Message->new_from_payload($payload); }),
   "xPL::Message->new_from_payload: Message badly terminated: ".
     "missing final eol char?",
   "missing eol warning");

$payload =
"xpl-stat
hop=1
source=vendor-device-instance
target=*
}
fred.schema
{
param1=value1
}
";
is(test_error(sub { $msg = xPL::Message->new_from_payload($payload); }),
   "xPL::Message->new_from_payload: Invalid header: xpl-stat
hop=1
source=vendor-device-instance
target=*",
   "badly formatted head");

$payload =
"xpl-stat
{
hop=1
source=vendor-device-instance
target=*
}
fred.schema
param1=value1
}
";
is(test_error(sub { $msg = xPL::Message->new_from_payload($payload); }),
   "xPL::Message->new_from_payload: Invalid body: fred.schema
param1=value1",
   "badly formatted body");

$ENV{XPL_MSG_WARN}=1;
is(test_warn(sub { $msg = xPL::Message->new(class => "unknown.schema") }),
   "Failed to load xPL::Message::unknown::schema: ".
     "Can't locate xPL/Message/unknown/schema.pm in \@INC",
   "xPL::Message unknown schema warning");

delete $ENV{XPL_MSG_WARN};

is(test_error(sub { $msg =
                       xPL::Message->new(message_type => "xpl-stat",
                                         head =>
                                         {
                                          source => "vendor-device.instance",
                                          hop => 10,
                                         },
                                         class => "fred.schema",
                                        ); }),
   "xPL::Message->hop: hop count, 10, is invalid.
It should be a value from 1 to 9",
   "invalid hop");

is(test_error(sub { $msg =
                      xPL::Message->new(message_type => "xpl-stat",
                                        head =>
                                        {
                                         source => "vendor-device.instance",
                                         target => 'invalid',
                                        },
                                        class => "fred.schema",
                                       ); }),
   "xPL::Message->target: target, invalid, is invalid.
Invalid format - should be 'vendor-device.instance'.",
   "invalid target");

is(test_error(sub { $msg = xPL::Message->new_from_payload(""); }),
   'xPL::Message->new_from_payload: Message badly formed: empty?',
   'empty message passed to new_from_payload');

$msg = xPL::Message->new(message_type => "xpl-stat",
                         head =>
                         {
                          source => "vendor-device.instance",
                         },
                         class => "fred.schema",
                         );

is(test_error(sub { xPL::Message->make_body_field() }),
   'xPL::Message->make_body_field: BUG: missing body field record',
   'make_body_field without field record');

is(test_error(sub { xPL::Message->make_body_field({}) }),
   'xPL::Message->make_body_field: '.
     'BUG: missing body field record missing name',
   'make_body_field with name in field record');

is(test_error(sub { xPL::Message->make_body_field({ name => 'test' }) }),
   'xPL::Message->make_body_field: '.
     'BUG: missing body field record missing validation',
   'make_body_field with name in field record');