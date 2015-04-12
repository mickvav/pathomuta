#!/usr/bin/perl
print 'CREATE TABLE `clinvar` (
'; 
$type{Integer} = 'INT';
$type{Flag} = 'CHAR(20)';
$type{String}= 'VARCHAR(100)';
print "`CHROM` CHAR(20) COMMENT 'Chromosome',
`POS` INT COMMENT 'Position',
`rsId` INT UNSIGNED "
while(<>){
  if(/^##INFO<(.*)>/) {
     @fields=split(/,/,$1);
     %args=();
     foreach $field (@fields) {
        ($name,$value)=split(/=/);
        $args{$name}=$value;
     };
     print '`info_'.$args{ID}.'` '.$type{$args{Type}}.' COMMENT '.$args{Description}.",\n";
    
  };
  
};
