module ringbuffer;

import core.stdc.stdint;

struct RingBuffer(T, size_t S) {
    private template IndexType() {
        static if (S <= UINT_FAST8_MAX)
            alias IndexType = uint_fast8_t;
        else static if (S <= UINT_FAST16_MAX)
            alias IndexType = uint_fast16_t;
        else static if (S <= UINT_FAST32_MAX)
            alias IndexType = uint_fast32_t;
        else
            alias IndexType = size_t;
    }

    IndexType!() available;
    IndexType!() read;
    IndexType!() write;
    T[S] data;

    bool put(T item) {
        if (available == S)
            return false;
        data[write] = item;
        write = (write + 1) % S;
        available++;
        return true;
    }

    bool take(out T dest) {
        if (available == 0)
            return false;  
        dest = data[read];
        read = (read + 1) % S;
        available--;
        return true;
    }

    T take() {
        T val;
        take(val);
        return val;
    }

    bool hasData() {
        return available > 0;
    }
}