#include <stdio.h>

int main(void)
{
    int n = 7;
    int t1 = 0, t2 = 1, nextTerm = 0;

    for (int i = 1; i <= n; ++i)
    {
        if (i == 1)
        {
            nextTerm = t1;
            continue;
        }
        if (i == 2)
        {
            nextTerm = t2;
            continue;
        }
        nextTerm = t1 + t2;
        t1 = t2;
        t2 = nextTerm;
    }
    return nextTerm;
}
