#!/usr/bin/perl

use strict;
use Getopt::Long;
use Aggregator;

my $currency = "GBP";
my $rates_file = "rates.csv";
my $transactions_file = "transactions.csv";
my $result_file = "aggregated_transactions_by_partner.csv";
my $partner_name;

GetOptions(
  'currency=s' => \$currency,
  'rates=s' => \$rates_file,
  'transactions=s' => \$transactions_file,
  'partner=s' => \$partner_name,
  'result=s' => \$result_file
);

die(<<EOM
error: partner name not specified!

usage: $0 \\
  --currency=$currency \\
  --rates=$rates_file \\
  --transactions=$transactions_file \\
  --result=$result_file \\
  --partner="partner name"
EOM
) if (!$partner_name);

my $app = new Aggregator(
  currency => $currency,
  exchangerates => $rates_file,
  transactions => $transactions_file,
  partner => $partner_name,
  result => $result_file
);

$app->run();

1;
