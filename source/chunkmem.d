module chunkmem;

import core.stdc.stdint : int64_t;
import memc;
import arraylist;

struct Chunk(size_t S) {
    size_t index;
    int64_t[S] data;
}

struct ChunkMemory(size_t S) {
    auto chunkPtrs = ArrayList!(Chunk!S*)(4);

    ~this() {
        foreach (chunk; chunkPtrs)
            free(chunk);
    }

    Chunk!S* ensureChunkFor(size_t ind) {
        auto chunkIndex = ind / S;

        foreach (chunk; chunkPtrs)
            if (chunk.index == chunkIndex)
                return chunk;

        auto chunk = malloc!(Chunk!S, true);
        chunk.index = chunkIndex;
        chunkPtrs.pushBack(chunk);
        return chunk;
    }

    ref int64_t opIndex(size_t ind) {
        pragma(inline, true);
        auto chunk = ensureChunkFor(ind);
        return chunk.data[ind % S];
    }
}