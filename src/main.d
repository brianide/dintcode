import core.stdc.stdio;
import vm;
static import day2;
static import day5;
static import day7;

struct Mode {
    const char* name;
    void function(ref Program) handler;
    const char* desc;
}

immutable static Mode[] modes = [
    {"day2s", &day2.runSilver, "Gravity Assist"},
    {"day2g", &day2.runGold,   "Parameter Modes"},
    {"day5s", &day5.runSilver, "T.E.S.T."},
    {"day5g", &day5.runGold,   "Jumps & Comparisons"},
    {"day7s", &day7.runSilver, "Amplification Circuit"},
    {"day7g", &day7.runGold,   "Feedback Loop"}
];

auto findMode(const char* name) {
    import core.stdc.string : strcmp;

    foreach(ref mode; modes)
        if (strcmp(name, mode.name) == 0) {
            return &mode;
    }

    return null;
}

int usage(const char* selfname) {
    fprintf(stderr, "Usage: %s file [mode]\n\n", selfname);
    fprintf(stderr, "  MODE  DESCRIPTION\n");
    foreach(ref mode; modes)
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