module vm;

import core.stdc.stdint;
import core.stdc.stdlib : calloc, realloc, free;
import ringbuffer;

struct Program {
    size_t length;
    int64_t* data;

    ~this() {
        free(data);
    }

    auto opIndex() {
        return data[0 .. length];
    }
}

Program readProgram(const char* path) {
    import core.stdc.stdio : FILE, fopen, fclose, fscanf, feof;

    size_t capacity = 1024;
    int64_t* buffer = cast(int64_t*) calloc(capacity, int64_t.sizeof);
    size_t cursor = 0;

    FILE* f = fopen(path, "r");
    int64_t value;
    while (!feof(f) && fscanf(f, "%ld,", &value) == 1) {
        if (cursor == capacity) {
            capacity *= 1.5;
            buffer = cast(int64_t*) realloc(buffer, capacity * int64_t.sizeof);
        }
        buffer[cursor++] = value;
    }
    fclose(f);

    buffer = cast(int64_t*) realloc(buffer, cursor * int64_t.sizeof);
    return Program(cursor, buffer);
}

enum Opcode {
    add = 1,
    multiply,
    input,
    output,
    jumpTrue,
    jumpFalse,
    lessThan,
    equals,
    halt = 99
}

struct OpData {
    const char* name;
    uint_fast8_t argc;
    Opcode code;
}

static immutable OpData[] opdata = [
    {"HLT", 0, Opcode.halt},
    {"ADD", 3, Opcode.add},
    {"MUL", 3, Opcode.multiply},
    {"INP", 1, Opcode.input},
    {"OUT", 1, Opcode.output},
    {"JNZ", 2, Opcode.jumpTrue},
    {"JZE", 2, Opcode.jumpFalse},
    {"TLT", 3, Opcode.lessThan},
    {"TEQ", 3, Opcode.equals},
];

enum MaxArgs = function uint_fast8_t() {
    uint_fast8_t max = 0;
    foreach (op; opdata)
        if (op.argc > max)
            max = op.argc;
    return max;
}();

enum Mode {
    position,
    immediate
}

enum State: uint_fast8_t {
    ok = 1 << 0,
    outputFull = 1 << 1,
    inputEmpty = 1 << 2,
    halted = 1 << 3,
    invalid = 1 << 4
}

struct VM {
    State state;
    size_t ip;
    int64_t[4096] memory;
    auto input = RingBuffer!(int64_t, 32)();
    auto output = RingBuffer!(int64_t, 32)();

    void loadProgram(ref Program prog) {
        import core.stdc.string : memcpy;
        memcpy(this.memory.ptr, prog.data, prog.length * int64_t.sizeof);
    }

    bool getNextOp(out immutable(OpData)* op, out int64_t*[MaxArgs] params) {
        auto inst = memory[ip] % 100;
        inst = (inst >> 5) ^ inst;
        if (inst >= opdata.length)
            return false;
        op = &opdata[inst];

        auto modes = memory[ip] / 10;
        foreach (i; 0 .. op.argc) {
            switch ((modes /= 10) % 10) {
                case Mode.position:
                    params[i] = &memory[memory[ip + 1 + i]];
                    continue;
                case Mode.immediate:
                    params[i] = &memory[ip + 1 + i];
                    continue;
                default:
                    return false;
            }
        }

        return true;
    }

    void step() {
        immutable(OpData)* op;
        int64_t*[MaxArgs] p;

        if (!getNextOp(op, p)) {
            state = State.invalid;
            return;
        }

        final switch (op.code) {
            case Opcode.add:
                *p[2] = *p[0] + *p[1];
                ip += 1 + op.argc;
                break;
            case Opcode.multiply:
                *p[2] = *p[0] * *p[1];
                ip += 1 + op.argc;
                break;
            case Opcode.input:
                if (input.take(*p[0]))
                    ip += 1 + op.argc;
                else
                    state = State.inputEmpty;
                break;
            case Opcode.output:
                if (output.put(*p[0]))
                    ip += 1 + op.argc;
                else
                    state = State.outputFull;
                break;
            case Opcode.jumpTrue:
                if (*p[0])
                    ip = *p[1];
                else
                    ip += 1 + op.argc;
                break;
            case Opcode.jumpFalse:
                if (!*p[0])
                    ip = *p[1];
                else
                    ip += 1 + op.argc;
                break;
            case Opcode.lessThan:
                *p[2] = *p[0] < *p[1] ? 1 : 0;
                ip += 1 + op.argc;
                break;
            case Opcode.equals:
                *p[2] = *p[0] == *p[1] ? 1 : 0;
                ip += 1 + op.argc;
                break;
            case Opcode.halt:
                state = State.halted;
                break;
        }
    }

    State runUntil(uint_fast8_t flags) {
        while (!(state & flags))
            step();
        return state;
    }

    State run() {
        while (state == state.ok)
            step();
        return state;
    }
}