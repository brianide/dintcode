module util.memc;

import clib = core.stdc.stdlib;
import core.lifetime : emplace;
// import cstr = core.stdc.string;

T* malloc(T, bool Z = false)() {
    T* ptr = cast(T*) clib.malloc(T.sizeof);
    assert(ptr);
    static if (Z)
        emplace!T(ptr);
    return ptr;
}

T* calloc(T, bool Z = false)(size_t count) {
    T* ptr = cast(T*) clib.calloc(count, T.sizeof);
    assert(ptr);
    static if (Z)
        foreach (i; 0 .. count)
            emplace!T(&ptr[i]);
    return ptr;
}

T* realloc(T)(ref T* ptr, size_t newCap) {
    T* newPtr = cast(T*) clib.realloc(ptr, newCap * T.sizeof);
    assert(newPtr);
    ptr = newPtr;
    return ptr;
}

T* realloc(T)(ref T* ptr, size_t oldSize, size_t newSize) {
    ptr = realloc(ptr, newSize);
    foreach (i; oldSize .. newSize)
        emplace(&ptr[i]);
    return ptr;
}

void free(T, bool D = false)(T* ptr) {
    static if (D)
        destroy!false(*ptr);
    clib.free(ptr);
}