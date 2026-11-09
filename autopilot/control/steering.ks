FUNCTION SetSteering {
    PARAMETER _heading, _pitch.
    
    SetAttitudeTarget(_heading, _pitch, 0).
}

FUNCTION GetCurrentAttitude {
    RETURN LEXICON(
        "HEADING", SHIP:HEADING,
        "PITCH", SHIP:PITCH,
        "ROLL", SHIP:ROLL
    ).
}

FUNCTION GetAngularVelocity {
    RETURN LEXICON(
        "PITCH_RATE", SHIP:ANGULARVEL:X,
        "ROLL_RATE", SHIP:ANGULARVEL:Y,
        "YAW_RATE", SHIP:ANGULARVEL:Z
    ).
}

FUNCTION GetSteeringQuality {
    LOCAL error IS MeasureAttitudeError().
    
    IF error < 2 {
        RETURN "EXCELLENT".
    } ELSE IF error < 5 {
        RETURN "GOOD".
    } ELSE IF error < 10 {
        RETURN "ACCEPTABLE".
    } ELSE {
        RETURN "POOR".
    }
}
