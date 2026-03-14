#include <stdio.h>

int main(void)
{
    int a = 0x0F0F;
    int b = 0xF0F0;
    int c = a ^ b;
    return c;
}
