module util.logger;

import core.stdc.stdio : vfprintf, stderr;
import core.stdc.stdarg;

enum LogLevel {
    TRACE,
    DEBUG,
    INFO,
    ERROR
}

private LogLevel logLevel = LogLevel.ERROR;

void setLogLevel(LogLevel level) {
    logLevel = level;
}

private void vlog(LogLevel level, const char* fmt, va_list args) {
    if (logLevel <= level) {
        vfprintf(stderr, fmt, args);
    }
}

void trace(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog(LogLevel.TRACE, fmt, args);
    va_end(args);
}

void dbg(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog(LogLevel.DEBUG, fmt, args);
    va_end(args);
}

void info(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog(LogLevel.INFO, fmt, args);
    va_end(args);
}

void error(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog(LogLevel.ERROR, fmt, args);
    va_end(args);
}