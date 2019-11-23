# ModuleLogging.jl

This package allows selective logging by module.

One use case is to turn on debug logging only for your own modules 
but not any other third-party modules.  

For convenience, two constructor functions are provided. 
The first one creates an underlying `SimpleLogger`. 
```
ModuleLogger(stream::IO, level::Logging.LogLevel, modules::Module...)
ModuleLogger(logger::AbstractLogger, modules::Module...)
```

Example:
```
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

logger = ModuleLogger(stderr, Logging.Debug, @__MODULE__, Foo)
global_logger(logger)
Foo.foo()
Bar.bar()
```
