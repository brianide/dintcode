module util.memc;

import clib = core.stdc.stdlib;
import cstr = core.stdc.string;

T* malloc(T, bool Z = false)() {
    void* ptr = clib.malloc(T.sizeof);
    assert(ptr);
    static if (Z)
        cstr.memset(ptr, 0, T.sizeof);
    return cast(T*) ptr;
}

T* calloc(T, bool Z = false)(size_t count) {
    void* ptr = clib.calloc(count, T.sizeof);
    assert(ptr);
    static if (Z)
        cstr.memset(ptr, 0, count * T.sizeof);
    return cast(T*) ptr;
}

T* realloc(T)(ref T* ptr, size_t newCap) {
    void* newPtr = clib.realloc(ptr, newCap * T.sizeof);
    assert(newPtr);
    ptr = cast(T*) newPtr;
    return ptr;
}

T* realloc(T)(ref T* ptr, size_t oldSize, size_t newSize) {
    T* ptr = realloc(ptr, newSize);
    cstr.memset(ptr + oldSize, 0, newSize - oldSize);
}

void free(T)(T* ptr) {
    clib.free(ptr);
}