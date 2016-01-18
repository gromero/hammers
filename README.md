# hammers
Little hammer bash scripts to help everyday duties

## findout.sh

I really need to find out where an address whose access renders a SIGSEGV.

So I take a picture before a stack overflow occurs `pmap -X <pid> > before_overflow.txt` and then I inspected the mapped pages for address 0x3fffff7fffc0 (from where I got the SIGSEGV) this way:

```shell
./findout.sh ./before_overflow.txt 0x3fffff7fffc0
10000000	 - 10010000	 r-xp invoke
10010000	 - 10020000	 r--p invoke
10020000	 - 10030000	 rw-p invoke
3fffb7d50000	 - 3fffb7f10000	 r-xp libc-2.21.so
3fffb7f10000	 - 3fffb7f20000	 r--p libc-2.21.so
3fffb7f20000	 - 3fffb7f30000	 rw-p libc-2.21.so
3fffb7f30000	 - 3fffb7f50000	 r-xp libpthread-2.21.so
3fffb7f50000	 - 3fffb7f60000	 r--p libpthread-2.21.so
3fffb7f60000	 - 3fffb7f70000	 rw-p libpthread-2.21.so
3fffb7f70000	 - 3fffb7f80000	 rw-p
3fffb7f80000	 - 3fffb7fa0000	 r-xp [vdso]
3fffb7fa0000	 - 3fffb7fe0000	 r-xp ld-2.21.so
3fffb7fe0000	 - 3fffb7ff0000	 r--p ld-2.21.so
3fffb7ff0000	 - 3fffb8000000	 rw-p ld-2.21.so
3ffffffd0000	 - 400000010000	 rw-p [stack]
STACK  @ 0x3ffffffd0000
SIGNAL @ 0x3fffff7fffc0
SIGNAL DISTANCE FROM STACK: 8192064 byte(s)
```
Two snapshots for quick understanding: 

![Address outside mapped pages](http://goo.gl/1bAhMI)

![Address inside mapped pages](http://goo.gl/2V7cI1)
