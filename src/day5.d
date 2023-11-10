module day5;

import core.stdc.stdint;
import core.stdc.stdio;
import vm;

void runSilver(ref Program prog) {
    auto vm = VM();
    vm.loadProgram(prog);
    vm.input.put(1);
    vm.run();

    foreach (i; 1 .. vm.output.available)
        vm.output.take();
    printf("%lu\n", vm.output.take());
}

void runGold(ref Program prog) {
    auto vm = VM();
    vm.loadProgram(prog);
    vm.input.put(5);
    vm.run();
    printf("%lu\n", vm.output.take());
}