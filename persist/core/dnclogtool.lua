DNC.loglevel = {
    INFO = Color("00ffff"),
    WARN = Color("ffff00"),
    ERROR = Color("ff0000")
}

function DNC.logMessageInGame(msg, color)
    managers.chat:_receive_message(1, "DNC", tostring(msg), color)
end

function DNC.logMessageOutGame(msg, color)
    managers.mission._fading_debug_output:script().log(msg, color)
end

DNCLogMessage = true
