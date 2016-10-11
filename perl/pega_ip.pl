#!/usr/bin/perl

use strict;
use warnings;

my $linha = "";

while(<>){

$linha = $_;

if ( $linha =~ /(\d+\.\d+\.\d+\.\d+)/ ) {

$linha = $1;
print "$linha\n";
}
}
