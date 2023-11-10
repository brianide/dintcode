module arraylist;

import core.stdc.stdlib : realloc, free;
import core.stdc.stdio;

enum GrowFactor = 1.5;

struct ArrayList(T) {
    size_t capacity;
    size_t count;
    T* items;

    this(size_t capacity) {
        this.capacity = capacity;
        this.count = 0;
        resize_array(items, capacity);
    }

    ~this() {
        free(items);
    }

    void push_back(T item) {
        if (count == capacity) {
            resize_array(items, cast(size_t) (capacity * GrowFactor));
        }
        items[count++] = item;
    }

    auto opIndex() {
        return items[0 .. count];
    }

    ref T opIndex(size_t ind) {
        return items[ind];
    }
}

private void resize_array(T)(ref T* list, size_t new_cap) {
    list = cast(T*) realloc(list, new_cap * T.sizeof);
}