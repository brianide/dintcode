module day5;

import core.stdc.stdint;
import core.stdc.stdio;
import vm;

struct Handler(int64_t V) {
    int64_t lastValue;
    
    size_t capacity() {
        return SIZE_MAX;
    }
    
    int64_t get() {
        return V;
    }

    void set(int64_t val) {
        lastValue = val;
    }

    auto getModule() {
        return IOModule(&capacity, &get, &capacity, &set);
    }
}

void runSilver(ref Program prog) {
    scope auto vm = VM();
    vm.loadProgram(prog);

    auto handler = Handler!1();
    vm.io = handler.getModule();
    vm.run();

    printf("%lu\n", handler.lastValue);
}

void runGold(ref Program prog) {
    scope auto vm = VM();
    vm.loadProgram(prog);

    auto handler = Handler!5();
    vm.io = handler.getModule();
    vm.run();

    printf("%lu\n", handler.lastValue);
}