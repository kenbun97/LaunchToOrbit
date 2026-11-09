FUNCTION AltitudeToRadius {
    PARAMETER _altitude.
    RETURN SHIP:BODY:RADIUS + _altitude.
}

FUNCTION CalculateSemimajorAxis {
    PARAMETER _periapsis, _apoapsis.
    RETURN (_periapsis + _apoapsis) / 2 + SHIP:BODY:RADIUS.
}

FUNCTION CalculateEccentricity {
    PARAMETER _periapsis, _apoapsis.
    RETURN (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
}

FUNCTION CalculateMeanMotion {
    PARAMETER semimajor_axis.
    LOCAL mu IS SHIP:BODY:MU.
    RETURN SQRT(mu / (semimajor_axis ^ 3)).
}

FUNCTION CalculateOrbitalPeriod {
    PARAMETER semimajor_axis.
    LOCAL n IS CalculateMeanMotion(semimajor_axis).
    RETURN 2 * 3.14159 / n.
}

FUNCTION GetBodyParameter {
    PARAMETER body_name, parameter_name.
    
    IF parameter_name = "RADIUS" {
        RETURN SHIP:BODY:RADIUS.
    } ELSE IF parameter_name = "MU" {
        RETURN SHIP:BODY:MU.
    } ELSE IF parameter_name = "ATMOSPHERE_HEIGHT" {
        RETURN SHIP:BODY:ATM:HEIGHT.
    }
    
    RETURN 0.
}

FUNCTION PredictApoapsis {
    RETURN SHIP:APOAPSIS.
}

FUNCTION PredictPeriapsis {
    RETURN SHIP:PERIAPSIS.
}
