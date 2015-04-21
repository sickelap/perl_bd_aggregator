#!/usr/bin/env perl

package Aggregator;

use strict;

sub new {
  my ($class, %params) = @_;
  my $self = {};
  $self->{_partner} = $params{partner};
  $self->{_rates} = $params{exchangerates};
  $self->{_transactions} = $params{transactions};
  $self->{_currency} = $params{currency};
  $self->{_result_filename} = $params{result};

  $self->{transactions} = [];

  bless($self, $class);
  return $self;
}

sub run {
  my ($self) = @_;

  $self->{rates} = $self->readExchangeRates($self->{_rates});
  $self->{transactions} = $self->readTransactions($self->{_transactions});
  $self->{aggregate} = $self->buildAggregateResult();
  $self->writeResultFile();
  $self->printResult();
}


sub readExchangeRates {
  my ($self, $filename) = @_;
  my %result;

  open FILE, "<$filename" or die "Can't open file $filename: $!\n";
  while (<FILE>) {
    chomp;
    my ($fromCurrency, $toCurrency, $rate) = split /,/;
    $result{$fromCurrency} = {} if (!$result{$fromCurrency});
    $result{$fromCurrency}{$toCurrency} = $rate;
  }
  close FILE;

  return \%result;
}

sub readTransactions {
  my ($self, $filename) = @_;
  my @result;

  open FILE, "<$filename" or die "Can't open file $filename: $!\n";
  while (<FILE>) { chomp;
    my ($partner, $currency, $amount) = split /,/;
    my %item = (
      partner => $partner,
      currency => $currency,
      amount => $amount
    );
    push @result, \%item;
  }
  close FILE;

  return \@result;
}

sub buildAggregateResult {
  my ($self) = @_;
  my %result;

  foreach (@{$self->{transactions}}) {
    $result{$_->{partner}} = 0 if (!$result{$_->{partner}});
    $result{$_->{partner}} += $self->getTransactionAmount($_, $self->{_currency});
  }

  return \%result;
}

sub writeResultFile {
  my ($self) = @_;

  open OUTFILE, ">$self->{_result_filename}" or die("Can't open file for writting: $!\n");
  while (my ($partner, $amount) = each %{$self->{aggregate}}) {
    print OUTFILE "$partner,$amount\n";
  }
  close OUTFILE;
}

sub printResult {
  my ($self) = @_;
  my $partner = $self->{_partner};

  print $self->{aggregate}{$partner} . "\n";
}

sub getTransactionAmount {
  my ($self, $transaction, $toCurrency) = @_;
  my $fromCurrency = $transaction->{currency};

  return ($fromCurrency eq $toCurrency)
    ? $transaction->{amount}
    : $transaction->{amount} * $self->getRate($fromCurrency, $toCurrency)
}

sub getRate {
  my ($self, $fromCurrency, $toCurrency) = @_;
  
  return $self->{rates}{$fromCurrency}{$toCurrency};
}

1;
