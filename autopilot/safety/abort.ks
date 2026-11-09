FUNCTION ExecuteAbort {
    PARAMETER reason IS "User-initiated abort".
    
    PRINT "ABORT: " + reason.
    SET GUIDANCE_STATE TO "ABORTING".
    
    KUNIVERSE:TIMEWARP:CANCELWARP().
    SET SHIP:CONTROL:MAINTHROTTLE TO 0.
    UNLOCK STEERING.
    UNLOCK THROTTLE.
    
    WriteTelemetryBuffer().
    CloseTelemetryFile().
    
    FOR i IN RANGE(0, DEFAULTS["ABORT_BEEP_COUNT"]) {
        PRINT "BEEP".
        WAIT DEFAULTS["ABORT_BEEP_INTERVAL"].
    }
    
    SET GUIDANCE_STATE TO "DISENGAGED".
    PRINT "Autopilot disengaged. Flight control returned to pilot.".
}

FUNCTION BindAbortSystem {
    ON AG10 {
        IF GUIDANCE_STATE <> "DISENGAGED" AND GUIDANCE_STATE <> "INITIALIZATION" {
            ExecuteAbort("Action Group 10 activated").
        }
    }
    
    PRINT "Abort system armed.".
}
