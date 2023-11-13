module day2;

import core.stdc.stdint;
import core.stdc.stdio;
import vm;

static int64_t runWith(ref Program prog, int64_t noun, int64_t verb) {
    auto vm = VM(prog);
    vm.memory[1] = noun;
    vm.memory[2] = verb;
    vm.run();
    return vm.memory[0];
}

void runSilver(ref Program prog) {
    printf("%ld\n", runWith(prog, 12, 2));
}

void runGold(ref Program prog) {
    foreach(i; 0..100)
        foreach(j; 0..100)
            if (runWith(prog, i, j) == 19_690_720) {
                printf("%d\n", i * 100 + j);
                return;
            }
}