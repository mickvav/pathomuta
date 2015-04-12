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
my $sth1=$dbh->prepare('DELETE from CGA_XR');
$sth1->execute();
my $sth=$dbh->prepare('SELECT ROWID,info_CGA_XR from MUTATIONS');
$sth->execute();

my $sthelem = $dbh->prepare(q{
    insert into CGA_XR (ROWID,rsId) values (?,?)
})          or die $dbh->errstr;
my $i=0;
while (my ($id, $cga) = $sth->fetchrow_array())
{
     my @cgas=split(/[&,]/,$cga);
     foreach my $elem (@cgas) {
        if($elem=~/^dbsnp.\d+\|rs(\d+)$/) {
 #            print "id: $id, rs:$1\n";
            $sthelem->execute($id,$1);
        } else {
             print "elem:$elem\n";
        };
     };
     $i++;
     if($i>1000) {

        $dbh->commit();
        $i=0;
     };
}
$dbh->disconnect();
