module modes.stdio;

import core.stdc.stdint : int64_t;
import core.stdc.stdio : scanf, feof, stdin, printf;
import vm.vm;

void runProg(ref Program prog) {
    scope auto vm = VM();
    vm.io.inputAvailable = () => feof(stdin) ? 0 : 1;
    vm.io.inputProvider = () {
        int64_t buffer;
        scanf("%ld,", &buffer);
        return buffer;
    };
    vm.io.outputCapacity = () => 1;
    vm.io.outputHandler = (a) { printf("%ld\n", a); };
    vm.loadProgram(prog);
    vm.run();
}