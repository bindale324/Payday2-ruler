DNC.loglevel = {
    INFO = Color("00ffff"),
    WARN = Color("ffff00"),
    ERROR = Color("ff0000")
}

function DNC.logMessage(msg, color)
    managers.mission._fading_debug_output:script().log(msg, color)
end

DNCLogMessage = true
