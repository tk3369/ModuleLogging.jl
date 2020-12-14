# ModuleLogging.jl

[![Build Status](https://github.com/tk3369/ModuleLogging.jl/workflows/CI/badge.svg)](https://github.com/tk3369/ModuleLogging.jl/actions?query=workflow%3ACI)

This package allows selective logging by module.

One use case is to turn on debug logging only for your own modules 
but not any other third-party modules.  

For convenience, two constructor functions are provided. 
The first one creates an underlying `SimpleLogger`. 
```julia
ModuleLogger(stream::IO, level::Logging.LogLevel, modules::Module...)
ModuleLogger(logger::AbstractLogger, modules::Module...)
```

Example:
```julia
module Foo
    function foo()
        @debug "foo called"
        return 1
    end
end

module Bar
    function bar()
        @debug "bar called"
        return 2
    end
end

using Logging, ModuleLogging
using .Foo
using .Bar

# Turn on debug logging for Foo module only
logger = ModuleLogger(stderr, Logging.Debug, Foo)
global_logger(logger)

Foo.foo()    # debug log is displayed
Bar.bar()    # no debug log
```
