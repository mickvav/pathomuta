#!/usr/bin/perl

use CGI;
use File::Basename; 
our $RE_File_ext='(csv|CSV)';
our $RE_Filename='[A-Za-z0-9\-_]*\.'.$RE_File_ext;
$query=new CGI;
my $filename = $query->param("datafile"); 
if ( !$filename ) {
  print $query->header();
  print "There was a problem uploading your file";
  exit(0);
};
my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' );
$extension=lc($extension);
if(!($extension eq 'csv')) {
  print $query->header();
  print "Only NimbleGene .csv files are supported for now"
  exit(0); 
};
if(!$name =~ /^$RE_Filename$/) {
  print "File name should contain only these characters: A-Z a-z 0-9 - _"
  exit(0); 
};


