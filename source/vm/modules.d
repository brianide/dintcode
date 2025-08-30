module vm.modules;

import core.stdc.stdint;
import util.ringbuffer;
import vm.vm;

struct QueueIOModule(size_t I, size_t O = I) {
    RingBuffer!(int64_t, I) input;
    RingBuffer!(int64_t, O) output;

    bool provideInput(ref int64_t val) {
        input.take(val);
        return true;
    }

    bool handleOutput(ref int64_t val) {
        output.put(val);
        return true;
    }

    auto getModule() {
        return IOModule(
            &provideInput,
            &handleOutput
        );
    }

    bool pushInput(int64_t val) {
        return input.put(val);
    }

    int64_t getOutput() {
        return output.take();
    }
}