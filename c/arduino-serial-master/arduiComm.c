#include <stdio.h>    // Standard input/output definitions
#include <stdlib.h>
#include <string.h>   // String function definitions
#include <unistd.h>   // for usleep()

#include "arduino-serial-lib.h"
#define SERIALPORTDEBUG 

void error(char* msg)
{
    fprintf(stderr, "%s\n",msg);
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
    const int buf_max = 256;

    int fd = -1;
    char serialport[buf_max];
    int baudrate = 9600;  // default
    char quiet=0;
    char eolchar = '\n';
    int timeout = 5000;
    char buf[buf_max];
    int rc,n;

    char bufstdin[buf_max];
    strcpy(serialport,"/dev/ttyACM0");
    fd = serialport_init(serialport, baudrate);
    if( fd==-1 ) error("couldn't open port");
    if(!quiet) printf("opened port %s\n",serialport);
    serialport_flush(fd);
/*    if(fork() == 0){
        while(fgets(bufstdin, sizeof buf, stdin)){
            if (bufstdin[strlen(bufstdin)-1] == '\n') {
            // read full line
        //        if( !quiet ) printf("send string:%s\n", bufstdin);
                rc = serialport_write(fd, bufstdin);
                if(rc==-1) error("error writing");
            }
        }
    } else {
*/        memset(buf,0,buf_max);  //
        while(serialport_read_until(fd, buf, eolchar, buf_max, timeout)){
            if( !quiet ) printf("read string:");
            printf("%s\n", buf);
        }
 //   }
//    exit(EXIT_SUCCESS);
}

