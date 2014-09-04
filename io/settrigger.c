 /****************************************************************************
 *      settrigger.c for PCI-DIO-24                                          *
 *                                                                           *
 *  This program uses a PCI-DIO-24 ACCES IO card to set trigger bits on a    *
 *  BioSemi USB module.  Bits 22-37 of the IO card must be connected to bits *
 *  1-16 of the BioSemi trigger in/out port.                                 *
 *                                                                           *
 *  Compile:                                                                 *
 *     sudo make                                                             *
 *     sudo cp settrigger /bin/                                              *
 *     sudo chmod 4755 /bin/settrigger                                       *
 *                                                                           *
 *  Syntax:                                                                  *
 *     settrigger <base_addr> <pinK1> <pinK2> <pinK3> ...                    *
 *                                                                           *
 *  Notes:                                                                   *
 *     Get the base address using the pcifind.plx                            *
 *                                                                           *
 *  LAST MODIFICATION: 2012-03-26                                            *
 *                                                                           *
 *****************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <sys/io.h>
#include <ctype.h>

unsigned int PortA;
unsigned int PortB;
unsigned int PortControl;

typedef enum {FALSE,TRUE} boolean;

int main(int argc, char *argv[])
{
   unsigned char byteA = 0;
   unsigned char byteB = 0;
   
   iopl(3);

   //make sure we have enough inputs
     if(argc<2){
        exit(1);
     }
   //parse the base address
     sscanf(argv[1], "%x", &PortA);
     PortB = PortA + 1;
     PortControl = PortA + 3;
   //set all ports to output
     //outb(0x8b,PortControl);
     outb(0x80,PortControl);
   //get the new trigger value
     int nPin = argc - 2;
     
     int k;
     for(k=0; k<nPin; k++){
        int kPin = atoi(argv[k+2]);
        
        if(kPin<9){
        //PortA
           byteA |= 1 << (kPin-1);
        }else{
        //PortB
           byteB |= 1 << (kPin-9);
        }
     }
   //set the trigger value
     outb(byteA,PortA);
     outb(byteB,PortB);

   iopl(0);
   return 0;
}

