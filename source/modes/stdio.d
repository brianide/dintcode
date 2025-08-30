module modes.stdio;

import core.stdc.stdint : uint64_t, int64_t;
import core.stdc.stdio : scanf, feof, stdin, printf;
import vm.vm;

void runProg() {
    scope auto vm = VM();
    vm.io.handleInput = (ref int64_t arg) {
        scanf("%ld,", &arg);
        return true;
    };

    vm.io.handleOutput = (ref int64_t arg) {
        printf("%ld\n", arg);
        return true;
    };
    
    // Get program length prefix
    uint64_t length;
    scanf("%ld", &length);

    // Read program from stdin
    auto prog = readProgram((ref int64_t value) {
        if (length-- <= 0)
            return false;
        return scanf("%ld,", &value) == 1;
    });
    vm.loadProgram(prog);
    vm.run();

    vm.run();
}