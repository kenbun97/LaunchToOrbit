FUNCTION CalculatePeriapsisDeltaV {
    LOCAL target_peri IS MISSION_CONFIG["TARGET_PERIAPSIS"].
    LOCAL current_apo IS SHIP:APOAPSIS.
    LOCAL current_peri IS SHIP:PERIAPSIS.
    
    LOCAL mu IS SHIP:BODY:MU.
    LOCAL r_apo IS current_apo + SHIP:BODY:RADIUS.
    LOCAL r_peri_target IS target_peri + SHIP:BODY:RADIUS.
    
    LOCAL a_current IS (r_apo + current_peri + SHIP:BODY:RADIUS) / 2.
    LOCAL a_target IS (r_apo + r_peri_target) / 2.
    
    LOCAL v_peri_current IS SQRT(mu * (2 / (current_peri + SHIP:BODY:RADIUS) - 1 / a_current)).
    LOCAL v_peri_target IS SQRT(mu * (2 / (current_peri + SHIP:BODY:RADIUS) - 1 / a_target)).
    
    RETURN ABS(v_peri_target - v_peri_current).
}

FUNCTION CalculateApoapsisDelataV {
    LOCAL target_apo IS MISSION_CONFIG["TARGET_APOAPSIS"].
    LOCAL current_apo IS SHIP:APOAPSIS.
    LOCAL current_peri IS SHIP:PERIAPSIS.
    
    LOCAL mu IS SHIP:BODY:MU.
    LOCAL r_peri IS current_peri + SHIP:BODY:RADIUS.
    LOCAL r_apo_target IS target_apo + SHIP:BODY:RADIUS.
    
    LOCAL a_current IS (current_apo + SHIP:BODY:RADIUS + r_peri) / 2.
    LOCAL a_target IS (r_apo_target + r_peri) / 2.
    
    LOCAL v_apo_current IS SQRT(mu * (2 / (current_apo + SHIP:BODY:RADIUS) - 1 / a_current)).
    LOCAL v_apo_target IS SQRT(mu * (2 / (current_apo + SHIP:BODY:RADIUS) - 1 / a_target)).
    
    RETURN ABS(v_apo_target - v_apo_current).
}

FUNCTION CalculateInclinationDeltaV {
    RETURN 0.
}

FUNCTION PredictPostBurnOrbit {
    PARAMETER delta_v.
    
    RETURN LEXICON(
        "APOAPSIS", SHIP:APOAPSIS,
        "PERIAPSIS", SHIP:PERIAPSIS + delta_v * 100,
        "INCLINATION", SHIP:ORBIT:INCLINATION
    ).
}
