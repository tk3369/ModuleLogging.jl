module ModuleLogging

export ModuleLogger

# using Lazy: @forward
using MacroTools
import Logging: AbstractLogger, SimpleLogger, Info
import Logging: shouldlog, handle_message, min_enabled_level, catch_exceptions

# SimpleLogger wrapper
struct ModuleLogger{T <:AbstractLogger} <: AbstractLogger
    logger::T
    modules::Set{Module}
end

# Constructors

ModuleLogger(stream::IO=stderr, level=Info, modules::Module...; kwargs...) = 
    ModuleLogger(SimpleLogger(stream, level; kwargs...), Set(modules))

ModuleLogger(logger::T, modules::Module...) where T <: AbstractLogger =
    ModuleLogger(logger, Set(modules))

# Should log only if the module is being monitored

shouldlog(logger::ModuleLogger, level, _module, group, id) = begin
    _module ∈ logger.modules &&
        shouldlog(logger.logger, level, _module, group, id)
end

# forward macro that supports keyword arguments
# (upstream PR - https://github.com/MikeInnes/Lazy.jl/pull/112)
macro forward(ex, fs)
    @capture(ex, T_.field_) || error("Syntax: @forward T.x f, g, h")
    T = esc(T)
    fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
    :($([:($f(x::$T, args...; kwargs...) = (Base.@_inline_meta; $f(x.$field, args...; kwargs...)))
         for f in fs]...);
      nothing)
end

# Delegate to underlying logger
@forward ModuleLogger.logger handle_message, min_enabled_level, catch_exceptions

end # module
