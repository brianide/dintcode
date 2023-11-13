module chunkmem;

import core.stdc.stdint : int64_t;
import memc;
import arraylist;

struct Chunk(size_t S) {
    size_t offset;
    int64_t[S] data;
}

struct ChunkMemory(size_t S) {
    ArrayList!(Chunk!S*) chunkPtrs;

    void initialize() {
        chunkPtrs = ArrayList!(Chunk!S*)(4);
    }

    ~this() {
        foreach (chunk; chunkPtrs)
            free(chunk);
    }

    Chunk!S* ensureChunkFor(size_t ind) {
        foreach (chunk; chunkPtrs) {
            if (chunk.offset <= ind && ind - chunk.offset < S)
                return chunk;
        }
        auto chunk = malloc!(Chunk!S, true)();
        chunk.offset = cast(size_t) (ind * 1f / S) * S;
        chunkPtrs.pushBack(chunk);
        return chunk;
    }

    ref int64_t opIndex(size_t ind) {
        auto chunk = ensureChunkFor(ind);
        return chunk.data[ind - chunk.offset];
    }
}