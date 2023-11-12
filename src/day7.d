module day7;

import core.stdc.stdio;
import core.stdc.stdint;
import vm;
import modules : QueueIOModule;

void swap(T)(ref T a, ref T b) {
    T x = a;
    a = b;
    b = x;
}

struct PermRange(T) {
    T[] items;

    int generate(size_t k, scope int delegate(T[]) dg) {
        if (k == 1)
            return dg(items);
        else {
            foreach (i; 0 .. k) {
                if (int res = generate(k - 1, dg))
                    return res;
                swap(items[k % 2 ? 0 : i], items[k - 1]);
            }
        }
        return 0;
    }

    int opApply(scope int delegate(T[]) dg) {
        return generate(items.length, dg);
    }
}

auto permutations(int[] list) {
    return PermRange!int(list);
}

void runSilver(ref Program prog) {
    int[5] settings = [0, 1, 2, 3, 4];
    int64_t max = 0;

    foreach (perm; permutations(settings)) {  
        int64_t input = 0;
        foreach (phase; perm) {
            scope auto vm = VM();
            auto io = QueueIOModule!2();
            vm.io = io.getModule();
            vm.loadProgram(prog);

            io.pushInput(phase);
            io.pushInput(input);
            vm.run(); 
            input = io.getOutput();
        }
        max = max > input ? max : input;
    }

    printf("%lu\n", max);
}

void runGold(ref Program prog) {
    int[5] settings = [5, 6, 7, 8, 9];
    int64_t max = 0;

    foreach (perm; permutations(settings)) {  
        QueueIOModule!2[5] ioms;
        VM[5] vms;

        foreach (i; 0 .. 5) {
            vms[i].loadProgram(prog);
            vms[i].io = ioms[i].getModule();
            ioms[i].pushInput(perm[i]);
        }
        
        auto cycle = 0;
        int64_t inputVal = 0;
        for (;;) {
            auto ind = cycle % 5;
            ioms[ind].pushInput(inputVal);
            auto res = vms[ind].runUntil(Event.needInput);
            inputVal = ioms[ind].getOutput();

            if (ind == 4 && res != Event.needInput)
                break;
            else
                cycle++;
        }

        max = max > inputVal ? max : inputVal;
    }

    printf("%lu\n", max);
}