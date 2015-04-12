#include <string.h>
#include <stdio.h>
#include <malloc.h>
#define FIELDS 80
#define MAX_LEN 20000

int main (int argc, char* argv[])
{
   if(argc<3)
   {
      printf("Введите имя и ID файла!\n");
      return 0;
   }

   FILE *fp;
   int c, i, N;
   int n = 0;
   int field = 0;
   int field_used = 0;
   int newline = 1;
   int info = 0;
   int info1 = 0;
   int info_key = 0;
   int info_value = 0;
   int cn = 0;
   int fields_num = 0;
   int format_keys = 0;
   int format_values = 0;
   int format_key = 0;
   int format_value = 0;
   int format_key1 = 0;
   int k;

   char* keys[FIELDS];
   char* values[FIELDS];

   for(i=0; i<FIELDS; i++)
   {
      keys[i] = malloc(MAX_LEN);
      values[i] = malloc(MAX_LEN);
   }

   char buffer[MAX_LEN+7];
   char buffer1[MAX_LEN+7];

   fp = fopen(argv[1],"r");
   if(fp == NULL) 
   {
      perror("Не удалось открыть файл.\n");
      return(-1);
   }
   do
   {
      c = fgetc(fp);
      if(feof(fp))
      {
          break ;
      }
      if(newline)
      {
        //printf("\nCHROM='", field);
        keys[0] = "CHROM";
        cn = 0;
      }
      switch(c)
      {
        case '\t' :
            if(format_keys == 1) 
            {
                  /*printf(", ");*/ buffer[cn+7] = '\0'; strcpy(keys[field], buffer); cn = 0; 
            }
            if(info_value == 1)
            { 
                  buffer1[cn]='\0'; strcpy(values[field], buffer1); cn = 0;
                  field_used = field+1; //info_value = 0;
	    }
            field++; 
            switch(field)
            {
              case 1 :
                //printf("', POS='");
                keys[1] = "POS";
                break;
              case 2 :
                //printf("', ID='");
                keys[2] = "ID"; 
                break;
              case 3 :
                //printf("', REF='");
                keys[3] = "REF";
                break;
              case 4 :
                //printf("', ALT='");
                keys[4] = "ALT";
                break;
              case 5 :
               // printf("', QUAL='");
                keys[5] = "QUAL";
                break;
              case 6 :
                //printf("', (%d)FILTER='",field);
                keys[6] = "FILTER";
                break;
              case 7 :
                info = 1;
                info1 = 1;      
                info_key = 1;        
                break;
              default:
                if((format_values == 0)&&(format_keys == 0)) { info_value=0; format_keys = 1; format_key1 = 1; cn=0; format_key = 1;}
                else if(format_keys == 1) { format_values = 1; format_keys = 0; cn = 0; format_value = 1; }
            }
            cn = 0;
            newline = 0;
            if((info == 1) && (field>7)) info = 0;
            break;
        case '\n' :
            //printf("'\n");

            //Сгенерировать MySQL-код
            printf("INSERT INTO `MUTATIONS` (");
            printf("`FILEID`, ");
            for(i=0; i<field_used-1; i++)
            {
               printf("`%s`, ", keys[i]);
            }
            printf("`%s`", keys[field_used-1]);

            printf(") VALUES (");
            printf("\"%s\", ",argv[2]);
            for(i=0; i<field_used-1; i++)
            {
               printf("\"%s\", ", values[i]);
            }
            printf("\"%s\"", values[field_used-1]);
            printf(");\n");

            field = 0;
            format_keys = 0;
            format_values = 0;
            newline = 1;
            break;
   	default :
            if(info == 1) 
            {
              if(info1 == 1)
              {
                 /*printf("(%d)info_", field);*/ info1 = 0; cn = 0;
                 buffer[0]='i'; buffer[1]='n'; buffer[2]='f'; buffer[3]='o'; buffer[4]='_';
              }              
              if(c=='=') 
              {
                 /*printf("='");*/ buffer[cn+5]='\0'; strcpy(keys[field], buffer); info_key = 0; info_value = 1; cn = 0;
              }
              else if(c==';')
              {
                 /*printf("', ");*/ buffer1[cn]='\0'; strcpy(values[field], buffer1);
                 field++; info1 = 1; info_key = 1; info_value = 0; cn = 0;
              }              
              else
              {
                 /*putchar(c);*/ if(info_key == 1) buffer[cn+5] = c; 
                             if(info_value == 1) buffer1[cn] = c; cn++;
              }
            }
            else if(format_keys == 1)
            {
               if(format_key1 == 1) 
               {
                  /*printf("(%d)format_", field);*/ format_key1 = 0;
                  buffer[0]='f'; buffer[1]='o'; buffer[2]='r'; buffer[3]='m'; buffer[4]='a'; 
                  buffer[5]='t'; buffer[6]='_'; cn = 0;
               }
               if(c == ':')
               {
                  /*printf(", ");*/ format_key1 = 1; buffer[cn+7] = '\0'; strcpy(keys[field], buffer); cn = 0; field++;
               }
               else
               {
                  /*putchar(c);*/ if(format_key == 1) buffer[cn+7] = c; cn++; 
               }   
            }

            else
            {
               /*putchar(c);*/ values[field][cn] = c;
            }
            newline = 0;  
      }
   }while(1);

   fclose(fp);

   return(0);
}
