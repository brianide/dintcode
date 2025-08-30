module modes.binary;

import core.stdc.stdint : uint8_t, uint64_t, int64_t;
import core.stdc.stdio : feof, fread, fwrite, fflush, stdin, stdout;
import vm.vm;

enum ControlCode {
    term = 0x09,
    load = 0x10,
    input = 0x11,
    peek = 0x12
}

enum ResponseCode {
    output = 0x11,
    peek = 0x12
}

void sendMessage(ResponseCode code, int64_t[] vals) {
    fwrite(&code, uint8_t.sizeof, 1, stdout);
    fwrite(vals.ptr, int64_t.sizeof, vals.length, stdout);
}

void runProg() {
    scope auto vm = VM();
    vm.io.handleInput = (ref int64_t arg) {
        fread(&arg, int64_t.sizeof, 1, stdin);
        return true;
    };

    vm.io.handleOutput = (ref int64_t arg) {
        sendMessage(ResponseCode.output, [arg]);
        return true;
    };

    // Get program length prefix
    uint64_t length;
    fread(&length, uint64_t.sizeof, 1, stdin);

    // Read program from stdin
    auto prog = readProgram((ref int64_t value) {
        if (length-- <= 0)
            return false;
        return fread(&value, int64_t.sizeof, 1, stdin) == 1;
    });
    vm.loadProgram(prog);
    vm.run();
}