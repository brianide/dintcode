module modes.binary;

import core.stdc.stdint : uint8_t, int64_t;
import util.logger;
import vm.vm;

/*
*** COMMANDS
* 0x09 KILL []         Requests emulator termination
* 0x11 INPT [i64]      Continue with input
* 0x12 PEEK [i64]      Peek value at address
* 0x13 POKE [i64, i64] Poke value to address

*** RESPONSES
* 0x09 HALT []         Program halt
* 0x11 OUTP [i64]      Output from VM instruction
* 0x12 PEEK [i64, i64] Address and value from peek
*/

enum ControlCode { 
    kill = 0x09,
    inpt = 0x10,
    peek = 0x12,
    poke = 0x13
}

enum ResponseCode {
    halt = 0x09,
    outp = 0x11,
    peek = 0x12
}

void sendMessage(ResponseCode code, int64_t[] vals) {
    import core.stdc.stdio : fwrite, stdout, fflush;

    fwrite(&code, uint8_t.sizeof, 1, stdout);
    if (vals.length) {
        fwrite(vals.ptr, int64_t.sizeof, vals.length, stdout);
        fflush(stdout);
    }
}

bool readVal(T)(ref T buf) {
    import core.stdc.stdio : fread, stdin, feof;

    if (feof(stdin))
        return false;

    return fread(&buf, T.sizeof, 1, stdin) == 1;
}

bool processQueue(ref VM vm) {
    import core.stdc.stdio : fflush;

    // ControlCode code;
    uint8_t code;
    int64_t[2] buffer;

    while (readVal(code)) {
        switch (code) {
            case ControlCode.kill:
                return false;

            case ControlCode.inpt:
                if (!readVal(buffer[0])) {
                    return false;
                }
                if (vm.state == State.input) {
                    *vm.ioReg = buffer[0];
                    trace("Received input value: %ld\n", buffer[0]);
                    return true;
                }
                else {
                    trace("Not awaiting input; discarding value: %ld", buffer[0]);
                }
                continue;

            case ControlCode.peek:
                if (!readVal(buffer[0]))
                    return false;
                sendMessage(ResponseCode.peek, [vm.memory[buffer[0]]]);
                continue;
            
            case ControlCode.poke:
                if (!readVal(buffer[0]))
                    return false;
                if (!readVal(buffer[1]))
                    return false;
                vm.memory[buffer[0]] = buffer[1];
                continue;
            
            default:
                trace("Received invalid control code: %02x\n", code);
                return false;
        }
    }

    return false;
}

int runProg() {
    info("Binary runner starting\n");

    scope auto vm = VM();
    vm.io.handleOutput = (ref int64_t arg) {
        sendMessage(ResponseCode.outp, [arg]);
        return true;
    };

    // Get program length prefix
    int64_t length;
    if (!readVal(length))
        return 1;

    trace("Read program length of %ld\n", length);

    // Read program from stdin
    auto prog = readProgram((ref int64_t value) {
        if (length-- <= 0)
            return false;
        return readVal(value);
    });
    vm.loadProgram(prog);

    do {
        vm.runUntil(State.input);
        if (vm.state == State.halted)
            sendMessage(ResponseCode.halt, []);
    } while(processQueue(vm));

    return 0;
}