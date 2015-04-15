#include <stdio.h>

void main() {

 unsigned int i;
 unsigned int A;
 unsigned long long int B;
 A=sizeof(unsigned int);
 printf("unsigned int: %d\n",A);
 A=sizeof(unsigned long int);
 printf("unsigned long int: %d\n",A);
 A=sizeof(unsigned long long);
 printf("unsigned long long int: %d\n",A);
 B=0xF00000000000000F;
 for(i=0;i<10000000;i++) {
   A=__builtin_popcountll(B);
 };
 printf("Sum: %d\n",A);
};
