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
  char* Name;                      //!< for string names ==NULL for computed clusters.
} masked_cluster;

unsigned int cluster_masksize(masked_cluster *);
void join(masked_cluster *,masked_cluster *,masked_cluster *);
unsigned int cluster_distance(masked_cluster *, masked_cluster *);
unsigned int cluster_read(masked_cluster *, FILE* );
void         cluster_write(masked_cluster *, FILE* ,int ,int );
void cluster_write_name(masked_cluster *, FILE* ); 
masked_cluster * cluster_array_add(masked_cluster **, int *);
#endif
