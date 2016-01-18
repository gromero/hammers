#!/bin/bash

######################################
## $1 PID or filename
## $2 address to look for in mem-map
######################################
findout()
{

if [[ $1 =~ ^[0-9]+$ ]] ; then
   PAGES="pmap -X $1"	#it's a PID, use pmap
else
   PAGES="cat $1"	#or a file...
fi

SI_ADDR=$2

$PAGES | head --lines=-2 | tail --lines=+3 | gawk -v si_addr=$SI_ADDR --non-decimal-data \
'
function print_page_size(s)
{
 if (s < 1024) {
   ret = s" B ";
 } else if (s < 1024*1024) {
     ret = s/1024" KiB ";
   } else {
      ret = s/(1024*1024)" MiB ";
    }
 return ret;
}

BEGIN { last_end = 0; }

{
  # Count how many pages to compute end. Page unit is KiB.
  start = ("0x"$1)+0; size = ($6*1024); end = start + size;

  # See if the address we are looking for is out of an
  # allocated block (between blocks). If it does, compute
  # its relative distence from the page above and from page below.
  if ( last_end < si_addr && si_addr < start ) {
   print si_addr-last_end,"\t\t o",start-si_addr;
  }

  # If the address is inside an allocated block the start
  # and the end of the block and mark this fact with a plus (+)
  # signal.
  if ( start <= si_addr && si_addr <= end ) {
    printf ("%x\t + %x\t", start, end);
  } else {
      printf ("%x\t - %x\t", start, end);
  }
  print $2, $13, "=>", print_page_size(size);

  # If the block is assigned to be the stack of the main
  # process (parent ID), record its start address, since,
  # as stack grows downwards, the start address is a "border".
  if ( $0 ~ /\[stack\]/ ) {
    stack_border_addr=start;
  }

  # Update the current end address to be used in the next iteration,
  # as we need it to see if the address we are searching is in between
  # blocks, i.e., out side an allocated address.
  last_end = end;
}

END {
  # Print some nutritional facts, mainly how far the address provide is
  # from the parent address stack. Generally, the address we are searching
  # is were a SIGSEGV exception occurred, hence here I call it "SIGNAL".
  print "";
  printf("STACK  @ 0x%x\n", stack_border_addr);
  printf("SIGNAL @ 0x%x\n", si_addr);
  printf("SIGNAL DISTANCE FROM STACK: %d byte(s)\n",stack_border_addr-si_addr)}
'

}

findout $1 $2 # PID|filename Address
