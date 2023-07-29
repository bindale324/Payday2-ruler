DNC.loglevel = {
    INFO = Color("00ffff"),
    WARN = Color("ffff00"),
    ERROR = Color("ff0000")
}

function DNC.logMessage(msg, color)
    managers.chat:_receive_message(1, "DNC", tostring(msg), color)
end

DNCLogMessage = true
