module vm;

import core.stdc.stdint;
import core.stdc.stdlib : calloc, realloc, free;
import chunkmem;
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
    assert(f);
    scope (exit) fclose(f);

    int64_t value;
    while (!feof(f) && fscanf(f, "%ld,", &value) == 1) {
        if (cursor == capacity) {
            capacity = cast(size_t) (capacity * 1.5);
            buffer = cast(int64_t*) realloc(buffer, capacity * int64_t.sizeof);
        }
        buffer[cursor++] = value;
    }

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

// Table for quickly looking up information for each CPU instruction.
// We pack Halt (code 99) into the 0 slot by XORing the code we're
// looking up by itself shifted 5 bits to the right.
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

// Used to determine how big our statically-sized param buffer needs to be.
// Declaring this as a single-case enum ensures that it's handled by CTFE;
// very neat feature of D.
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

enum State {
    ok = 1 << 0,
    outputFull = 1 << 1,
    halted = 1 << 2,
    invalid = 1 << 3
}

enum Event {
    none,
    needInput = 1 << 0,
    output = 1 << 1,
    halt = 1 << 2,
    error = 1 << 3
}

struct IOModule {
    size_t delegate() inputAvailable;
    int64_t delegate() inputProvider;
    size_t delegate() outputCapacity;
    void delegate(int64_t) outputHandler;
}

struct VM {
    State state;
    size_t ip;
    ChunkMemory!2048 memory;
    IOModule io;

    void initialize(ref Program prog) {
        memory.initialize();
        loadProgram(this, prog);
    }

    this(ref Program prog) {
        initialize(prog);
    }
}

void loadProgram(ref VM vm, ref Program prog) {
    foreach (i; 0 .. prog.length)
        vm.memory[i] = prog.data[i];
}

bool getNextOp(ref VM vm, out immutable(OpData)* op, out int64_t*[MaxArgs] params) {
    auto inst = vm.memory[vm.ip] % 100;
    inst = (inst >> 5) ^ inst;
    if (inst >= opdata.length)
        return false;
    op = &opdata[inst];

    auto modes = vm.memory[vm.ip] / 10;
    foreach (i; 0 .. op.argc) {
        switch ((modes /= 10) % 10) {
            case Mode.position:
                params[i] = &vm.memory[vm.memory[vm.ip + 1 + i]];
                continue;
            case Mode.immediate:
                params[i] = &vm.memory[vm.ip + 1 + i];
                continue;
            default:
                return false;
        }
    }

    return true;
}

Event step(ref VM vm) {
    immutable(OpData)* op;
    int64_t*[MaxArgs] p;

    if (!vm.getNextOp(op, p)) {
        vm.state = State.invalid;
        return Event.error;
    }

    scope auto inc = () { vm.ip += 1 + op.argc; };

    final switch (op.code) {
        case Opcode.add:
            *p[2] = *p[0] + *p[1];
            inc();
            return Event.none;

        case Opcode.multiply:
            *p[2] = *p[0] * *p[1];
            inc();
            return Event.none;

        case Opcode.input:
            if (!vm.io.inputAvailable()) {
                return Event.needInput;
            }
            *p[0] = vm.io.inputProvider();
            inc();
            return Event.none;

        case Opcode.output:
            if (!vm.io.outputCapacity()) {
                vm.state = State.outputFull;
                return Event.error;
            }
            vm.io.outputHandler(*p[0]);
            inc();
            return Event.output;

        case Opcode.jumpTrue:
            if (*p[0])
                vm.ip = *p[1];
            else
                inc();
            return Event.none;

        case Opcode.jumpFalse:
            if (!*p[0])
                vm.ip = *p[1];
            else
                inc();
            return Event.none;

        case Opcode.lessThan:
            *p[2] = *p[0] < *p[1] ? 1 : 0;
            inc();
            return Event.none;

        case Opcode.equals:
            *p[2] = *p[0] == *p[1] ? 1 : 0;
            inc();
            return Event.none;

        case Opcode.halt:
            vm.state = State.halted;
            return Event.halt;
    }
}

State run(ref VM vm) {
    while (vm.state == State.ok)
        vm.step();
    return vm.state;
}

Event runUntil(ref VM vm, Event flags) {
    if (vm.state != State.ok)
        return Event.none;
    
    flags = flags | Event.halt | Event.error;

    Event event;
    do {
        event = vm.step();
    } while (!(event & flags));

    return event;
}