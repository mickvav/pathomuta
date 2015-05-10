#!/usr/bin/perl
use XML::Parser;
use Data::Dumper;
use strict;
use DBI;
my $dsn = 'DBI:mysql:mutfreq:localhost';
my $user= 'mutfreq';
my $password='mutfreq';

my $dbh = DBI->connect($dsn, $user, $password,
                    { RaiseError => 1, AutoCommit => 0 });

my $sthrsid = $dbh->prepare(q{
    insert into rs (rsId,Symbol,geneId,Frequency) values (?,?,?,?) on duplicate key update Symbol=values(Symbol),geneId=values(geneId),Frequency=values(Frequency)
})          or die $dbh->errstr;
my $sthhgvs = $dbh->prepare('insert into rshgvs (rsId,hgvs) values (?,?) on duplicate key update  rsId=values(rsId), hgvs=values(hgvs)')          or die $dbh->errstr;

my $rsid;
while(<>) {
  if(/<pre>/) {
    s/<pre>//;
    s/&gt;/>/g;
    s/&lt;/</g;
    my $line=$_;

    my $p1 = XML::Parser->new(Style => "Tree");
    my $res=$p1->parse($line);
# Maploc -> FxnSet -> symbol,geneId
    $rsid=$res->[1]->[0]->{rsId};
    my $freq=0;
    my @hvgs=();
    my $symbols='';
    my $geneids='';
    print "Rsid:".$rsid."\n";
    for my $i (0..@{$res->[1]}) {
       my $n=$res->[1]->[$i];
     
       if($n eq 'Frequency') {
         $freq=$res->[1]->[$i+1]->[0]->{freq};
       };
       if($n eq 'hgvs') {
         push @hvgs, $res->[1]->[$i+1]->[2];
       };
       if($n eq 'Assembly') {
         my $c=$res->[1]->[$i+1]->[2];
         for my $j (0..@{$c}) {
           if($c->[$j] eq 'MapLoc') {
              my %symbol=();
              my %geneId=();
              for my $k (0..@{$c->[$j+1]}) {
                 if($c->[$j+1]->[$k] eq 'FxnSet') {
                    foreach my $elem (@{$c->[$j+1]->[$k+1]}) {
                       $symbol{$elem->{'symbol'}}=1;
                       $geneId{$elem->{'geneId'}}=1;
                    };
                 };
              };
              $symbols=join(',',keys(%symbol));
              $geneids=join(',',keys(%geneId));
           }
         };
       };
#         print $i." ".$res->[1]->[$i]."\n";
      
    };
    $sthrsid->execute($rsid,$symbols,$geneids,$freq)   or die $sthrsid->errstr;
    
    $sthhgvs->bind_param_array(1,$rsid);
    $sthhgvs->bind_param_array(2,\@hvgs);
    $sthhgvs->execute_array( { ArrayTupleStatus => \my @tuple_status } )   or die $sthhgvs->errstr;

  };
    
  $dbh->commit();
  print "$rsid\n";
};
$dbh->disconnect();
