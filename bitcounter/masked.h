#ifndef _MASKED_H
#define _MASKED_H
#include <stdio.h>

#ifndef FIELDWIDTH
#define FIELDWIDTH 1
#endif

typedef struct {
  unsigned long int X[FIELDWIDTH]; //!< Value
  unsigned long int M[FIELDWIDTH]; //!< Inverse Mask
      long int rs;                 //!< rs number 
                                   //!< >0 for wild numbers
                                   //!< <0 for computed clusters
      long int cluster;            //!< parent cluster. 
                                   //!< =0 for undefined.
} masked_cluster;

unsigned int cluster_masksize(masked_cluster *A);
void join(masked_cluster *A,masked_cluster *B,masked_cluster *C);
unsigned int cluster_distance(masked_cluster *A, masked_cluster *B);
unsigned int cluster_read(masked_cluster *A, FILE* F);
void         cluster_write(masked_cluster *A, FILE* F,int length,int mode);
#endif
