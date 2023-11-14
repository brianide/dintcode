module day9;

import core.stdc.stdint;
import core.stdc.stdio;
import vm;

void runWith(ref Program prog, int64_t n) {
    scope auto vm = VM();
    vm.io.inputAvailable = () => 1;
    vm.io.inputProvider = () => n;
    vm.io.outputCapacity = () => 1;
    vm.io.outputHandler = (n) { printf("%ld\n"); };
    vm.loadProgram(prog);
    vm.run();
}

void runSilver(ref Program prog) {
    runWith(prog, 1);
}

void runGold(ref Program prog) {
    runWith(prog, 2);
}