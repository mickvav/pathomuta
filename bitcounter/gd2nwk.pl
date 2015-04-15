#!/usr/bin/perl
my $hash;
while(<>){
  if(/(-?\d+) -> (-?\d+)/) {
    $hash->{$2}->{$1}=1;
  };
};

sub printtree($) 
{
  my $me=$_[0];
  my @keys=keys(%{$hash->{$me}});
  if ($#keys>0) {
    print "(";
  }
  my $n=0;
  foreach my $k (@keys) {
     if($n==1) { print ','; };
     if(defined($hash->{$k})) {
       printtree($k);
       $n=1;
     } else {
       $n=1;
       print $k;
     };
  };
  if($#keys>0) {
     print ")";
  };
};

printtree('0');
print ";";
