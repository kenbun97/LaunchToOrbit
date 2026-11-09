GLOBAL THROTTLE_STATE IS LEXICON(
    "CURRENT", 0,
    "TARGET", 0,
    "RAMP_RATE", DEFAULTS["MAIN_THROTTLE_RATE"]
).

FUNCTION SetThrottle {
    PARAMETER target_throttle.
    
    SET target_throttle TO MAX(0, MIN(1, target_throttle)).
    SET THROTTLE_STATE["TARGET"] TO target_throttle.
    SET SHIP:CONTROL:MAINTHROTTLE TO target_throttle.
    SET THROTTLE_STATE["CURRENT"] TO target_throttle.
}

FUNCTION RampThrottle {
    PARAMETER target_throttle, rate.
    
    SET target_throttle TO MAX(0, MIN(1, target_throttle)).
    LOCAL current IS THROTTLE_STATE["CURRENT"].
    LOCAL step IS rate.
    
    IF current < target_throttle {
        SET THROTTLE_STATE["CURRENT"] TO MIN(target_throttle, current + step).
    } ELSE IF current > target_throttle {
        SET THROTTLE_STATE["CURRENT"] TO MAX(target_throttle, current - step).
    }
    
    SET SHIP:CONTROL:MAINTHROTTLE TO THROTTLE_STATE["CURRENT"].
    RETURN THROTTLE_STATE["CURRENT"].
}

FUNCTION GetThrottleStatus {
    RETURN LEXICON(
        "COMMAND", THROTTLE_STATE["CURRENT"],
        "ACTUAL", SHIP:CONTROL:MAINTHROTTLE,
        "TOTAL_THRUST", SHIP:THRUST,
        "TOTAL_THRUST_AVAILABLE", SHIP:MAXTHRUST
    ).
}

FUNCTION VerifyThrottleControl {
    LOCAL old_thrust IS SHIP:THRUST.
    SetThrottle(0.5).
    WAIT 0.5.
    LOCAL new_thrust IS SHIP:THRUST.
    
    IF new_thrust > old_thrust {
        RETURN TRUE.
    }
    RETURN FALSE.
}
