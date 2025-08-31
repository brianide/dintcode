import core.stdc.stdio;
import vm.vm;
static import modes.stdio;
static import modes.binary;
import util.logger;

int usage(FILE* file, int status, const char* selfname) {
    fprintf(file, "Usage:  %s [--log] (--stdio|--bin)\n\n", selfname, selfname);
    return status;
}

struct Options {
    bool log = false;
    bool binary = false;
    bool stdio = false;
}

bool match(ref const char* a, string b) {
    import core.stdc.string : strcmp;
    return strcmp(a, b.ptr) == 0;
}

bool parseOptions(const char*[] args, ref Options conf) {
    foreach(ref arg; args) {
        if (match(arg, "--log") && conf.log == false)
            conf.log = true;

        else if (!conf.binary && !conf.stdio) {
            if (match(arg, "--stdio"))
                conf.stdio = true;
            else if (match(arg, "--bin"))
                conf.binary = true;
        }

        else
            return false;
    }

    return true;
}

extern(C) int main(int argc, char** argv) {
    if (argc <= 1)
        return usage(stderr, 1, argv[0]);

    Options conf;
    if (!parseOptions(argv[1..argc], conf))
        return usage(stderr, 1, argv[0]);

    if (conf.log)
        setLogLevel(LogLevel.TRACE);

    if (conf.binary)
        return modes.binary.runProg();
    else if(conf.stdio) {
        modes.stdio.runProg();
        return 0;
    }

    return 1;
}