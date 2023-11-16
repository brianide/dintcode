import core.stdc.stdio;
import vm.vm;
static import modes.stdio;
static import modes.day2;
static import modes.day5;
static import modes.day7;
static import modes.day9;

struct Mode {
    const char* name;
    void function(ref Program) handler;
    const char* desc;
}

immutable static Mode[] runModes = [
    {"--",    &modes.stdio.runProg,  "Run with Standard I/O"},
    {"day2s", &modes.day2.runSilver, "Gravity Assist"},
    {"day2g", &modes.day2.runGold,   "Parameter Modes"},
    {"day5s", &modes.day5.runSilver, "T.E.S.T."},
    {"day5g", &modes.day5.runGold,   "Jumps & Comparisons"},
    {"day7s", &modes.day7.runSilver, "Amplification Circuit"},
    {"day7g", &modes.day7.runGold,   "Feedback Loop"},
    {"day9s", &modes.day9.runSilver, "Sensor Boost"},
    {"day9g", &modes.day9.runGold,   "Feature Complete"}
];

auto findMode(const char* name) {
    import core.stdc.string : strcmp;

    foreach(ref mode; runModes)
        if (strcmp(name, mode.name) == 0) {
            return &mode;
    }

    return null;
}

int usage(const char* selfname) {
    fprintf(stderr, "Usage: %s file [mode]\n\n", selfname);
    fprintf(stderr, "  MODE  DESCRIPTION\n");
    foreach(ref mode; runModes)
        fprintf(stderr, "%6s  %s\n", mode.name, mode.desc);
    return 1;
}

extern(C) int main(int argc, char** argv) {
    if (argc != 3)
        return usage(argv[0]);

    auto mode = findMode(argv[2]);
    if (!mode)
        return usage(argv[0]);

    auto prog = readProgram(argv[1]);
    mode.handler(prog);
    return 0;
}