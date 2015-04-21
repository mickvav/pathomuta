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
my $RE_kn='[a-zA-Z0-9_-]+';
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
my $current_subgraph='';
my $subgraphs=();
my $subgraph_by_node=();

sub print_subgraphs {
#
#  Prints all marked subgraphs.
#
  my $subgraphs_to_print=();
  $subgraphs_to_print->{''}=();
  foreach my $node (keys(%{$printed})) {
     $subgraphs_to_print->{$subgraph_by_node->{$node}}->{$node}=1;
  };
  foreach my $s (sort(keys(%{$subgraphs_to_print}))) {
    if($s ne '') { 
      print "subgraph $s {\n";
    };
    for my $j ('node','graph','rank','shape') {
      if(defined($subgraphs->{$s}->{$j})) {
        print $j." ".$subgraphs->{$s}->{$j}.";\n";
      }; 
    };
    for my $n (keys(%{ $subgraphs_to_print->{$s} })) { 
       print $n.' '.(defined($node->{$n}->{desc})?$node->{$n}->{desc}:'').";\n";
    };
    if($s ne '') {
      print "}\n";
    };
  };
};

my @lines=();

sub printup($$$) {
#
#  Recursive procedure, printing only necessary links and marking necessary nodes.
#
  my ($me,$nup,$ndown) = @_;
  if(defined($printed->{$me})) {
     return;
  };
#  print $me." ".$node->{$me}."\n";
  $printed->{$me}=1;
  if($nup>0) {
    foreach my $upper (keys(%{$revlink->{$me}})) {
       if(not(defined($printed->{$upper}))) {
         printup($upper,$nup-1,$ndown);
         my $l=$revlink->{$me}->{$upper};
         my $ps=$l->{ps};
         my $pe=$l->{pe};
         my $comm=$l->{comm};
         push @lines, $upper.(defined($ps)?$ps:'')." -> ".$me.(defined($pe)?$pe:'').(defined($comm)?' '.$comm : '').";\n";
       };
    };
  };
  if($ndown>0) {
    foreach my $downer (keys(%{$link->{$me}})) {
       if(not(defined($printed->{$downer}))) {
         printup($downer,$nup,$ndown-1);
         my $l=$link->{$me}->{$downer};
         my $ps=$l->{ps};
         my $pe=$l->{pe};
         my $comm=$l->{comm};
         push @lines, $me.(defined($ps)?$ps:'')." -> ".$downer.(defined($pe)?$pe:'').(defined($comm)?' '.$comm : '').";\n";
       };
    };
  };
};
while(<FD>) {
  chomp;
  if(/^\s*($RE_kn)(:$RE_kn)?\s*->\s*($RE_kn)(:$RE_kn)?\s*(\[.*\])?;?/) {  ## Link
    $link->{$1}->{$3}={ps => $2, pe => $4, comm => $5};
    $revlink->{$3}->{$1}={ps => $2, pe => $4, comm => $5};
  } elsif(/^\s*subgraph\s+($RE_kn)\s+{/) { ## subgraph
    $current_subgraph = $1;
  } elsif(/^\s*node\s+(\[.*\])\s*;?\s*$/) {
    $subgraphs->{$current_subgraph}->{node}=$1;
  } elsif(/^\s*graph\s+(\[.*\]);?/) {
    $subgraphs->{$current_subgraph}->{graph}=$1;
  } elsif(/^\s*(rank|shape)\s*=\s*([A-Za-z0-9]+)\s*;/) {
    $subgraphs->{$current_subgraph}->{$1}=$2;
  } elsif(/^\s*($RE_kn)\s+(\[.*\])\s*;?\s*$/) {
    $node->{$1}->{desc}=$2;
    $subgraphs->{$current_subgraph}->{nodes}->{$1}=1;
    $subgraph_by_node->{$1}=$current_subgraph;
  };
};
print "digraph G {\n";
printup($keynode,$Nup,$Ndown);
print_subgraphs();
foreach my $line (@lines) {
  print $line;
};
print "}";
