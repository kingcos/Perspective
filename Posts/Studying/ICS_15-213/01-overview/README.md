# Studying - ICS 15-213 Overview

## Preface

第一章概览，教授主要介绍了课程内容和安排等。

## Demo

```c
#include <stdio.h>
#include <stdlib.h>

int sq(int x) {
    return x*x;
}

int main(int argc, char *argv[]) {
    int i;
    for (i = 1; i < argc; i++) {
	int x = atoi(argv[i]);
	int sx = sq(x);
	printf("sq(%d) = %d\n", x, sx);
    }
    return 0;
}
```

```c
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int a[2];
    double d;
} struct_t;

double fun(int i) {
    volatile struct_t s;
    s.d = 3.14;
    s.a[i] = 1073741824; /* Possibly out of bounds */
    return s.d; /* Should be 3.14 */
}

int main(int argc, char *argv[]) {
    int i = 0;
    if (argc >= 2)
	i = atoi(argv[1]);
    double d = fun(i);
    printf("fun(%d) --> %.10f\n", i, d);
    return 0;
}
```

## Words List

monolithic
tagline
endeavor
quirky
entry
evolve
assumption
profound
rational number
hypothesis
bonkers
wire
effective
mildly
cornerstone
revise
retroactive
apprise
cheat
plagiarism
tempting
obligation
acquire
vengeful
mean
instructor
syllabus
fairly
relevant
disclose
queer
statute
interchangeable
pseudocode
fishy
suspicious
consequence
penalty
extenuating
circumstance
impose
expulsion
expel
tremendous
confess
appeal
unjust
screw up
procedure
tutor
extensive
prompt
bump
rusty
tweak
duplex
reveal
boot camp
mandatory
shaky