import core.stdc.stdio;
import core.stdc.string : strcmp;
import vm.vm;
static import modes.stdio;
static import modes.day2;
static import modes.day5;
static import modes.day7;
static import modes.day9;
static import modes.binary;

struct Mode {
    const char* name;
    void function(ref Program) handler;
    const char* desc;
}

immutable static Mode[] dayModes = [
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
    foreach(ref mode; dayModes)
        if (strcmp(name, mode.name) == 0) {
            return &mode;
    }

    return null;
}

int usage(FILE* file, int status, const char* selfname) {
    fprintf(file, "Usage:\n  %s file [day]\n  %s (--stdio|--bin)\n  %s -h\n\n", selfname, selfname, selfname);
    fprintf(file, "  DAY   DESCRIPTION\n");
    foreach(ref mode; dayModes)
        fprintf(file, "%6s  %s\n", mode.name, mode.desc);
    return status;
}

extern(C) int main(int argc, char** argv) {    
    if (argc == 2) {
        if (strcmp(argv[1], "--stdio") == 0) {
            modes.stdio.runProg();
            return 0;
        }

        if (strcmp(argv[1], "--bin") == 0) {
            modes.binary.runProg();
            return 0;
        }

        if (strcmp(argv[1], "-h") == 0)
            return usage(stdout, 0, argv[0]);

        return usage(stderr, 1, argv[0]);
    }

    if (argc != 3)
        return usage(stderr, 1, argv[0]);

    auto mode = findMode(argv[2]);
    if (!mode)
        return usage(stderr, 1, argv[0]);

    auto prog = readProgramFile(argv[1]);
    mode.handler(prog);
    return 0;
}