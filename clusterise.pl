#!/usr/bin/perl

use Algorithm::Cluster;
use strict;
use DBI;
use Data::Dumper;
my $dsn = 'DBI:mysql:mutfreq:localhost';
my $user= 'mutfreq';
my $password='mutfreq';

my $dbh = DBI->connect($dsn, $user, $password,
                    { RaiseError => 1, AutoCommit => 1 });

my $sth=$dbh->prepare('SELECT distinct(FILEID) from MUTATIONS');
$sth->execute();
my @filenumbers=();
while(my ($n) = $sth->fetchrow_array()) {
  push @filenumbers, $n;
};

$sth=$dbh->prepare('SELECT M.FILEID,C.rsId FROM CGA_XR C INNER JOIN MUTATIONS M ON M.ROWID=C.ROWID');
$sth->execute();
my $hash;
while(my($fileid,$rsId) = $sth->fetchrow_array())
{
   $hash->{$rsId}->{$fileid}=1;
};

my @data;
my $i=0;
my @k=keys(%$hash);
foreach my $rsId (@k) {
  my @row;
  foreach my $file (@filenumbers) {
     if(defined($hash->{$rsId}->{$file})) {
    push @row, 1;
  } else {
    push @row, 0;
  };
  };
  push @data, [ @row ];
};

my %param = (
  nclusters => 50,
  data => [ @data ],
  mask => '',
  weight => '',
  transpose => 0,
  dist => 'c',
  method => 'a', 
  initialid => [],
);
my ($res,$error,$nfound) =  Algorithm::Cluster::kcluster(%param);
my $rehash;
my $i=0;
foreach my $r (@$res) {
  $rehash->{$r}->{$k[$i]}=$i;
  $i++;
};

foreach my $r (keys(%{$rehash})) {
  my @rsids=keys(%{$rehash->{$r}});
  print "Cluster ".$r." ".$#rsids."\n";
  
  foreach my $rsid (@rsids) {
#    print $rsid.": ".join(',',keys(%{$hash->{$rsid}}))."\n";
    print $rsid.":\t".join('',@{$data[$rehash->{$r}->{$rsid}]})."\n";
  };
};
#print Dumper($res);
print STDERR Dumper($error);
print STDERR Dumper($nfound);
