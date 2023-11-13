module arraylist;

import core.stdc.stdio;
import memc;

enum DefaultGrowFactor = 1.5;

struct ArrayList(T, float G = DefaultGrowFactor) {
    size_t capacity;
    size_t count;
    T* items;

    this(size_t capacity) {
        this.capacity = capacity;
        this.count = 0;
        this.items = calloc!T(capacity);
    }

    ~this() {
        free(items);
    }

    void pushBack(T item) {
        if (count == capacity) {
            capacity = cast(size_t) (capacity * G);
            printf("%lu\n", capacity);
            realloc!T(items, capacity);
        }
        items[count++] = item;
    }

    void condense() {
        if (capacity > count) {
            capacity = count;
            realloc!T(items, capacity);
        }
    }

    auto opIndex() {
        return items[0 .. count];
    }

    ref T opIndex(size_t ind) {
        return items[ind];
    }
}