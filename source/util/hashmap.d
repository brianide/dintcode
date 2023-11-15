module util.hashmap;

import core.stdc.stdint;
import core.stdc.string;
import util.linkedlist;
import util.memc;

enum LoadFactor = 0.8;

struct HashMap(K,V) {
    struct Entry {
        K key;
        V value;
    }

    uint32_t function(K) keyFn = (v) => 0;
    size_t capacity;
    size_t count;
    LinkedList!Entry* entries;

    this(uint32_t function(K) keyFn) {
        this.keyFn = keyFn;
    }

    ~this() {
        if (entries) {
            free(entries);
        }
    }

    void put(K key, V value) {
        checkGrow();
        if (insertInto(entries, capacity, false, key, value))
            count++;
    }

    V get(K key) {
        auto ind = indexFor(keyFn(key), capacity);
        foreach (ent; entries[ind])
            if (ent.key == key)
                return ent.value;
        return V.init;
    }

    private void checkGrow() {
        if (!capacity) {
            // Initialize list
            capacity = 8;
            entries = calloc!(LinkedList!Entry, true)(8);
        }
        else if (count >= capacity * LoadFactor) {
            // Make a new entrylist
            auto newCap = capacity * 2;
            LinkedList!Entry* newEntries = calloc!(LinkedList!Entry, true)(newCap);

            // Rehash old entries
            foreach (i; 0 .. capacity) {
                foreach (entry; entries[i])
                    insertInto(newEntries, newCap, true, entry.key, entry.value);
                destroy!(false)(entries[i]);
            }

            // Chuck the old list
            free(entries);
            entries = newEntries;
            capacity = newCap;
        }
    }

    private bool insertInto(LinkedList!Entry* list, size_t capacity, bool skipCheck, ref K key, ref V value) {
        auto ind = indexFor(keyFn(key), capacity);
        if (!skipCheck)
            foreach (ref entry; list[ind])
                if (entry.key == key) {
                    entry.value = value;
                    return false;
                }
        list[ind].push(Entry(key, value));
        return true;
    }
}

private uint32_t indexFor(uint32_t h, size_t capacity) {
    h ^= (h >>> 20) ^ (h >>> 12);
    h ^= (h >>> 7) ^ (h >>> 4);
    return h & (capacity - 1);
}