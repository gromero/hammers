#!/bin/bash

findout()
{
 PID=$1
 SI_ADDR=$2

if [[ $1 =~ ^[0-9]+$ ]] ; then
   PAGES="pmap -X $1"	#it's a PID, use pmap
else
   PAGES="cat $1"	#or a file...
fi

#echo $PID
#echo $SI_ADDR

$PAGES | head --lines=-2 | tail --lines=+3 | gawk -v si_addr=$SI_ADDR --non-decimal-data '{ start = ("0x"$1)+0; end = start + ($6*1024); if ( start <= si_addr && si_addr <= end ) { printf ("%x\t + %x\t ", start,end) } else { printf ("%x\t - %x\t ", start, end) } ;  print $2, $13; if ( $0 ~ /\[stack\]/ ) { stack_border_addr=start } } END { printf("STACK  @ 0x%x\n", stack_border_addr); printf("SIGNAL @ 0x%x\n", si_addr); printf("SIGNAL DISTANCE FROM STACK: %d byte(s)\n",stack_border_addr-si_addr) }'
}

findout $1 $2
