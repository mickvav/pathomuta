#include <stdio.h>
#include <stdlib.h>
  /** \brief This script analises file given in it's first
   *         argument and prints FIELDWIDTH required to run 
   *         masked.c/masked.h on this data.
   */

int analise_read(FILE*F) {
  long int rs;
  int c,i,k,j;
  i=fscanf(F,"%ld",&rs);
  if(i==0) {
     fprintf(stderr,"Warning! Wrong file format!\n");
  };
  c='0';
  j=1;
  while((c!='\n')&&(c!=' ')&&(c!=EOF)) {
    c=fgetc(F);
    if(c=='1') { k++; i++; };
    if(c=='N') { k++; i++; };
    if(c=='0') { k++;i++; };
    if(i>8*sizeof(unsigned long int)) {
       j++;i=0; 
    };
  };
  if((i==0) && (j>1)) { j--;};
  if(c==' ') {
    i=fscanf(F,"%ld",&rs);
    if(i==0) {
       fprintf(stderr,"Warning! Wrong file format!\n");
    };
  };
  return j;
};

void main(int argc, char** argv) 
{
  FILE *F;
  int W=1;
  int W1=1;
  if(argc<2) {
    printf("Usage:\nanalise_file file.txt\n");
    exit(1);
  };
  F=fopen(argv[1],"r");
  if(NULL == F){
    perror("Problems opening file");
    exit(2);
  };
  while(!feof(F)) {
    W1=analise_read(F);
    if(W<W1) { W=W1; };
  };
  printf("%d",W);
};
