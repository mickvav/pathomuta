#!/usr/bin/perl
use strict;
if(not(defined($ARGV[3]))) {
  print "Usage: 
      getsubgraph.pl file.gv keynode N1 N2
         keynode - node to put in center.
         N1 - number of nodes to climb up.
         N2 - number of nodes to climb down.
";
  exit(1);
};

if ($ARGV[0] eq '-') {
   open(FD, '<&', \*STDIN) or die "Can't open STDIN. Hmm.\n";
} else {
   open(FD,'<'.$ARGV[0]) or die "Can't open file ".$ARGV[0]."\n";
};
my $keynode=$ARGV[1];
my $RE_kn='[a-zA-Z0-9-]+';
if(! ($keynode =~/^$RE_kn$/)) {
  die "Keynode should be a word consisting of A-Z a-z 0-9 -";
};
my $Nup=$ARGV[2];
my $Ndown=$ARGV[3];
if(! ($Nup =~ /^\d+$/)) { die "N1 should be integer!\n"; };
if(! ($Ndown =~ /^\d+$/)) { die "N2 should be integer!\n"; };

my $link;
my $revlink;
my $node;
my $printed;
sub printup($$$) {
  my ($me,$nup,$ndown) = @_;
  if(defined($printed->{$me})) {
     return;
  };
  print $me." ".$node->{$me};
  $printed->{$me}=1;
  if($nup>0) {
    foreach my $upper (keys(%{$revlink->{$me}})) {
       if(not(defined($printed->{$upper}))) {
         printup($upper,$nup-1,$ndown);
         print $upper." -> ".$me.";\n";
       };
    };
  };
  if($ndown>0) {
    foreach my $downer (keys(%{$link->{$me}})) {
       if(not(defined($printed->{$downer}))) {
         printup($downer,$nup,$ndown-1);
         print $me." -> ".$downer.";\n";
       };
    };
  };
};
while(<FD>) {
  if(/^\s*($RE_kn)\s*->\s*($RE_kn)\s*;/) {
    $link->{$1}->{$2}=1;
    $revlink->{$2}->{$1}=1;
  } elsif(/^\s*($RE_kn)\s+([^{]*)$/) {
    $node->{$1}=$2;
  };
};
print "digraph G {\n";
printup($keynode,$Nup,$Ndown);
print "}";
