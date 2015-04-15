#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "masked.h"
unsigned int cluster_masksize(masked_cluster *A) {
  /** \brief Compute number of masked characters in A
   */
  unsigned int D=0;
  unsigned int i;
  for(i=0;i<FIELDWIDTH;i++) {
     D+=__builtin_popcountll( ~(A->M[i]));
  };
};

void cluster_join(masked_cluster *A,masked_cluster *B,masked_cluster *C) {
  /** \brief Join two clusters A and B to form C as 
   *         bounding box for A and B.
   *         A and B get their cluster numbers point to C's 
   *         rs value.
   *
   */
  unsigned int i;
  for(i=0;i<FIELDWIDTH;i++) {
    C->M[i] = A->M[i] & B->M[i] & ( ~( A->X[i] ^ B->X[i] ) ) ;
    C->X[i] = (A->X[i] & B->X[i]) & C->M[i];
  }; 
  A->cluster = C->rs;
  B->cluster = C->rs;
};

unsigned int cluster_distance(masked_cluster *A, masked_cluster *B) {
  /** \brief Compute distance between two clusters, which is
   *         defined as minimal number of bits, which should 
   *         be changed in any element of A to get to some
   *         element of B.
   */
  unsigned int D=0;
  unsigned int i;
  for(i=0;i<FIELDWIDTH;i++) {
     D+=__builtin_popcountll( (A->X[i] ^ B->X[i]) & (A->M[i] & B->M[i])  );
  };
  return D;
};

unsigned int cluster_read(masked_cluster *A, FILE* F) {
  /** \brief Read single text line consisting of 
   *         vector number space character and line of 0 or 1 or N followed by optional (means parent!) cluster number. If absent, set to 0
   *         Returns number of successfully read bits.
   *
   *         Vector number can be arbitrary unsigned long int.
   *         N.B. - line of 0 and 1 should be no longer than 
   *          FIELDWIDTH*sizeof(unsigned long int)*8. 
   *         If it's not the case, consider recompiling with 
   *         increased FIELDWIDTH number.
   *         
   *         NB: N means 'put 0 in vector AND 0 in mask'
   *         thus meaning 'Any bit in this position'
   *         Any other non-space non-eoln characters
   *         will be skiped!
   */
  unsigned int i;
  unsigned int k=0;
  unsigned int j;
  unsigned int N;
  int c='0';
  i=0;
  A->cluster=0;
  for(j=0;j<FIELDWIDTH;j++) {  
    A->X[j]=0x0;
    A->M[j]=~0x0;
  };
  j=0;
  N=fscanf(F,"%ld",&(A->rs));
  assert(N>0);
  c=fgetc(F);
  c='0';
  while((c!='\n')&&(c!=' ')&&(c!=EOF)) {
    c=fgetc(F);
    if(c=='1') { A->X[j] |= (1<<i) ; k++; i++; };
    if(c=='N') { A->M[j] &= ~(1<<i); k++; i++; };
    if(c=='0') { k++;i++;};
    if(i>8*sizeof(unsigned long int)) {
      if(j<FIELDWIDTH-1) { j++;i=0; } else {
        fprintf(stderr, "Trying to read too long line!\n");
        exit(1);
      };
    };
  };
  if(c==' ') {
    N=fscanf(F,"%ld",&(A->cluster));
    assert(N>0);
  };
  return k;
};

void cluster_write(masked_cluster *A, FILE* F,int length,int mode) {
  /** \brief Write single text line consisting of 
   *         vector number space character and line of 0 or 1 or N
   *
   *         outputs cluster in cluster_read compatible way (mode=0)
   *              or in dot-style node (mode=1);
   */
  unsigned int i;
  unsigned int k;
  unsigned int j;
  int c='0';
  if(mode==0) {fprintf(F,"%ld ",A->rs);} else { fprintf(F,"%ld [shape=record, label=\"",A->rs); };
  for(k=0,i=0,j=0;k<length;k++) {
    if((~A->M[j]) & (1<<i)) {
       fprintf(F,"N");
    } else {
      if((A->X[j] ) & (1<<i)) {
       fprintf(F,"1");
      } else {
       fprintf(F,"0");
      };
    };
    i++;
    if(i>8*sizeof(unsigned long int)) {
      if(j<FIELDWIDTH-1) { j++;i=0; } else {
        fprintf(stderr, "Trying to write too long line!\n");
        exit(1);
      };
    };
  };
  if(A->cluster == 0){
     if(mode==0) {
       fprintf(F,"\n");
     } else {
       fprintf(F,"\"]\n");
     };
  } else {
     if(mode==0) {
       fprintf(F," %ld\n",A->cluster);
     } else {
       fprintf(F,"\"]\n");
     };
  };
};


