GLOBAL ATTITUDE_CONTROLLER IS LEXICON(
    "KP", 1.0,
    "KI", 0.1,
    "KD", 0.5,
    "INTEGRAL_ERROR", 0,
    "PREVIOUS_ERROR", 0
).

FUNCTION SetAttitudeTarget {
    PARAMETER _heading, _pitch, _roll.
    
    SET TARGET_HEADING TO _heading.
    SET TARGET_PITCH TO _pitch.
    SET TARGET_ROLL TO _roll.
    
    LOCK STEERING TO HEADING(_heading, _pitch, _roll).
}

FUNCTION MeasureAttitudeError {
    LOCAL heading_error IS ABS(SHIP:HEADING - TARGET_HEADING).
    LOCAL pitch_error IS ABS(SHIP:PITCH - TARGET_PITCH).
    LOCAL roll_error IS ABS(SHIP:ROLL - TARGET_ROLL).
    
    IF heading_error > 180 {
        SET heading_error TO 360 - heading_error.
    }
    
    RETURN SQRT(heading_error ^ 2 + pitch_error ^ 2 + roll_error ^ 2).
}

FUNCTION UpdatePIDGains {
    PARAMETER kp, ki, kd.
    
    SET ATTITUDE_CONTROLLER["KP"] TO kp.
    SET ATTITUDE_CONTROLLER["KI"] TO ki.
    SET ATTITUDE_CONTROLLER["KD"] TO kd.
}

FUNCTION GetControllerStatus {
    RETURN LEXICON(
        "TARGET_HEADING", TARGET_HEADING,
        "MEASURED_HEADING", SHIP:HEADING,
        "TARGET_PITCH", TARGET_PITCH,
        "MEASURED_PITCH", SHIP:PITCH,
        "TARGET_ROLL", TARGET_ROLL,
        "MEASURED_ROLL", SHIP:ROLL,
        "ATTITUDE_ERROR", MeasureAttitudeError()
    ).
}
