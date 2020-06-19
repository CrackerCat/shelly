#!/bin/bash

echo '[*] Assembling with nasm...'
nasm -f elf32 -o $1.o $1.nasm

echo '[*] Linking...'
ld -z execstack -o $1 $1.o

echo '[*] Extracting opcodes...'
shellcode=$(objdump -d ./$1|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g';)
echo $shellcode
echo ''

echo '[*] Creating shellcode...'
cat >shellcode-$1.c <<EOD
	#include<stdio.h>
	#include<string.h>
	unsigned char code[] = $shellcode;
	main()
	{
	  printf("Shellcode length: %d\n", strlen(code));
	  int (*ret)() = (int(*)())code;
	  ret();
	}
EOD

echo '[*] Compiling shellcode...'
gcc -fno-stack-protector -z execstack shellcode-$1.c -o shellcode-$1

echo '[+] Done!'
