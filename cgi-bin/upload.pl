#!/usr/bin/perl
use strict;
use DBI;
use CGI;
use Data::Dumper;
my $dsn = 'DBI:mysql:mutfreq:localhost';
my $dbuser= 'mutfreq';
my $dbpassword='mutfreq';

use File::Basename; 
our $RE_File_ext='(csv|CSV)';
my $RE_user='[A-Za-z0-9]+';
our $RE_Filename='[A-Za-z0-9\-_]*\.'.$RE_File_ext;
my $query=new CGI;
my $filename = $query->param("datafile"); 
if ( !$filename ) {
  print $query->header();
  print "There was a problem uploading your file";
  exit(0);
};
my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' );
$extension=lc($extension);
my $format='NimbleGene';
if($extension eq '.csv') {
  $format='NimbleGene';
} else {
  print $query->header();
  print "Only NimbleGene .csv files are supported for now.";
  exit(0); 
};
if(!$name =~ /^$RE_Filename$/) {
  print $query->header();
  print "File name should contain only these characters: A-Z a-z 0-9 - _";
  exit(0); 
};

my $user=$query->remote_user();
if(!$user =~/^$RE_user$/) {
  print $query->header();
  print "Bad user name $user! Go away!";
  exit(0); 
};

my $upload_filehandle = $query->upload("datafile");

my $dbh = DBI->connect($dsn, $dbuser, $dbpassword,
                    { RaiseError => 1, AutoCommit => 0 });

my $sth=$dbh->prepare('INSERT INTO files SET Owner="'.$user.'",FILENAME="'.$name.'"');
$sth->execute();
my $id=$sth->{mysql_insertid};

my $relation={
  'NimbleGene' => 
    {
      'Reference Accession Number' => 'CHROM',
      'Start Position in Ref' => 'POS',
      'Reference Bases' => 'REF',
      'Variation Bases' => 'ALT',
      'Total Variation Percent' => 'QUAL',
      'Known SNP Info' => 'info_CGA_XR'
    }
};

my @colnames=();
my $i=0;

print $query->header();

while(<$upload_filehandle>) {
  chomp;
  if(/Start Position in Ref/) {
    @colnames=split(/,/);
  };
  if($#colnames>1){
    sub replace_commas($) {
      my $line=$_[0];
      $line=~s/,/;/g;
      return $line;
    };
    s/"([^"]*)"/replace_commas($1)/eig;

    my @values=split(/,/);
    my %h=();
    for(my $i=0;$i<=$#values;$i++) {
      my $cname=$colnames[$i];
      print "<i>Here ($cname,$i,$values[$i])</i><br>"; 
      if(defined($relation->{$format}->{$cname})) {
         print "<b>Doit: $cname </b><br>";
         $h{$relation->{$format}->{$cname}}=$dbh->quote($values[$i]);
      };
    };
    if(defined($h{'info_CGA_XR'})) {
      my $statement='insert into MUTATIONS set FILEID='.$id.', '.join(',', map { $_.'='.$h{$_} } keys(%h) );
      my $sth=$dbh->prepare($statement);
      $sth->execute();
      $i++;
      if($i>1000) {
        $dbh->commit();
        $i=0;
      };
    } else {
      print '<pre>'.Dumper(\%h).'</pre>';   
    }

  } else {
    print "<pre>Line:\n".$_." ncolnames: ".$#colnames."</pre>";
  };
};
$dbh->commit();

$dbh->disconnect();

system("/usr/local/bin/process_cga_xr.pl ".$id);

  print "Ok. Done.";
  exit(0);
