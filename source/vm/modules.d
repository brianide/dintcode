module vm.modules;

import core.stdc.stdint;
import util.ringbuffer;
import vm.vm;

struct QueueIOModule(size_t I, size_t O = I) {
    RingBuffer!(int64_t, I) input;
    RingBuffer!(int64_t, O) output;

    size_t inputAvailable() {
        return input.available;
    }

    int64_t provideInput() {
        return input.take();
    }

    size_t outputCapacity() {
        return O - output.available;
    }

    void handleOutput(int64_t val) {
        output.put(val);
    }

    auto getModule() {
        return IOModule(
            &inputAvailable,
            &provideInput,
            &outputCapacity,
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