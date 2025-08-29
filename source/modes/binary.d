module modes.binary;

import core.stdc.stdint : uint64_t, int64_t;
import core.stdc.stdio : feof, fread, fwrite, fflush, stdin, stdout;
import vm.vm;

void runProg() {
    scope auto vm = VM();
    vm.io.inputAvailable = () => feof(stdin) ? 0 : 1;
    vm.io.inputProvider = () {
        int64_t buffer;
        fread(&buffer, int64_t.sizeof, 1, stdin);
        return buffer;
    };
    vm.io.outputCapacity = () => 1;
    vm.io.outputHandler = (a) {
        fwrite(&a, int64_t.sizeof, 1, stdout);
        fflush(stdout);
    };

    // Get program length prefix
    uint64_t length;
    fread(&length, uint64_t.sizeof, 1, stdin);

    // Read program from stdin
    Program prog = readProgram((ref int64_t value) {
        if (length-- <= 0)
            return false;
        return fread(&value, int64_t.sizeof, 1, stdin) == 1;
    });
    vm.loadProgram(prog);
    vm.run();
}