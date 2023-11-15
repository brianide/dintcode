module util.arraylist;

import core.stdc.stdio;
import util.memc;

enum DefaultCapacity = 8;
enum DefaultGrowFactor = 1.5;

struct ArrayList(T, float G = DefaultGrowFactor) {
    size_t capacity;
    size_t count;
    T* items;

    this(size_t capacity) {
        this.capacity = capacity;
        this.count = 0;
    }

    ~this() {
        if (items)
            free(items);
    }

    void pushBack(T item) {
        if (!items || count == capacity) {
            capacity = cast(size_t) (capacity * G);
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

    ref T opIndex(size_t ind) {
        assert(ind < count);
        return items[ind];
    }

    int opApply(scope int delegate(T) dg) {
        foreach (i; 0 .. count)
            if (int res = dg(items[i]))
                return res;
        return 0;
    }
}