import core.stdc.stdio;
import core.stdc.string : strcmp;
import vm.vm;
static import modes.stdio;
static import modes.binary;

int usage(FILE* file, int status, const char* selfname) {
    fprintf(file, "Usage:  %s (--stdio|--bin)\n\n", selfname, selfname);
    return status;
}

extern(C) int main(int argc, char** argv) {    
    if (argc != 2)
        return usage(stderr, 1, argv[0]);

    if (strcmp(argv[1], "--stdio") == 0) {
        modes.stdio.runProg();
        return 0;
    }

    if (strcmp(argv[1], "--bin") == 0) {
        modes.binary.runProg();
        return 0;
    }

    return usage(stderr, 1, argv[0]);
}