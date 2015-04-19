#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>
#include "masked.h"

masked_cluster **Pull=NULL;
int *Pullsizes=NULL;
int pulls=0;
void add_pull() {
   if(pulls==0) { // Nothing allocated. Let's do the job.
     Pull=(masked_cluster **)malloc(sizeof(void *));
     Pullsizes=(int*)malloc(sizeof(int));
     pulls=1;
     Pull[0]=NULL;
     Pullsizes[0]=0;
   } else { 
     pulls++;
     Pull=(masked_cluster **)realloc(Pull,pulls*sizeof(void*));
     Pullsizes=(int*)realloc(Pullsizes,pulls*sizeof(int));
     Pull[pulls-1]=NULL;
     Pullsizes[pulls-1]=0;
   };
};

void remove_pull() {
  int j;
  free(Pull[pulls-1]);
  Pull[pulls-1]=NULL;
  Pullsizes[pulls-1]=0;
  pulls--;
  for(j=0;j<Pullsizes[pulls-1];j++) {
     Pull[pulls-1][j].cluster=0;
  };
};

masked_cluster * add_to_pull_new(int Pnum) {
     int last=Pullsizes[Pnum];
     assert(Pnum<pulls);
     Pull[Pnum]=(masked_cluster*)realloc(Pull[Pnum],(last+1)*sizeof(masked_cluster));
     Pullsizes[Pnum]++;
     Pull[Pnum][last].cluster=0;
     Pull[Pnum][last].rs=0;
     return &(Pull[Pnum][last]);
};


void main(int argc, char**argv) {
  FILE *F;
  int lastcluster=-1;
  unsigned int bits=0;
  unsigned int maxbits=0;
  int i,j,k;
  int dist;
  int mindist;
  masked_cluster *A;
  masked_cluster *B;
  masked_cluster *C;
  if(argc<2) {
    fprintf(stderr,"Usage:\ncluster_tree file.txt\n");
    exit(1);
  };
  if(strcmp(argv[1],"-") == 0) {
    F=stdin;
  } else {
    F=fopen(argv[1],"r");
  };
  if(NULL == F){
    perror("Problems opening file");
    exit(2);
  };
  add_pull();
  while(!feof(F)) {
    A=add_to_pull_new(0);
    bits=cluster_read(A,F); 
    maxbits=(bits>maxbits?bits  : maxbits);
    if((bits==0)&&(Pullsizes[0]>0)) { Pullsizes[0]--; };
  };
  close(F);
  mindist=0;
  for(i=0;Pullsizes[i]>1;i++) {
    add_pull();
    for(j=0;j<Pullsizes[i];j++) {
      A=&(Pull[i][j]);
      if(A->cluster==0) {
        B=add_to_pull_new(i+1);
        B->rs=lastcluster--;
        cluster_join(A,A,B);
        for(k=j+1;k<Pullsizes[i];k++) {
          C=&(Pull[i][k]);
          if(C->cluster==0) {
            dist=cluster_distance(C,B);
            if(mindist>=dist) {
               cluster_join(B,C,B);
               B->cluster=0;
            };
          };
        }; 
      };
    }; 
    if(Pullsizes[i]==Pullsizes[i+1]) { // Nothing changed.
       mindist++;
       i--;
       remove_pull(); 
    } else { // Something changed. Starting from =0 distance
       mindist=0;
    };
  };
  printf("digraph G {\n");
  for(i=0;i<pulls;i++) {
    for(j=0;j<Pullsizes[i];j++) {
       cluster_write(&(Pull[i][j]),stdout,maxbits,2);
       
       printf("%ld -> %ld;\n", Pull[i][j].rs,Pull[i][j].cluster);
    }
    printf("\n");
  };
  printf("}");
  exit(0);
};

