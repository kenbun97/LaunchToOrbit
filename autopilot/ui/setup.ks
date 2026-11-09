FUNCTION ConfigureBodySelection {
    PRINT "Select active celestial body:".
    PRINT "1. Kerbin".
    PRINT "2. Mun".
    PRINT "3. Minmus".
    PRINT "4. Duna".
    
    LOCAL choice IS 1.
    SET MISSION_CONFIG["BODY"] TO KERBIN.
    RETURN MISSION_CONFIG["BODY"].
}

FUNCTION ConfigureOrbitParameters {
    PRINT "Configure target orbit:".
    
    LOCAL apo IS DEFAULTS["TARGET_APOAPSIS"].
    LOCAL peri IS DEFAULTS["TARGET_PERIAPSIS"].
    LOCAL inc IS DEFAULTS["TARGET_INCLINATION"].
    LOCAL raan IS DEFAULTS["TARGET_RAAN"].
    LOCAL arg_pe IS DEFAULTS["TARGET_ARG_OF_PERIAPSIS"].
    
    SET MISSION_CONFIG["TARGET_APOAPSIS"] TO apo.
    SET MISSION_CONFIG["TARGET_PERIAPSIS"] TO peri.
    SET MISSION_CONFIG["TARGET_INCLINATION"] TO inc.
    SET MISSION_CONFIG["TARGET_RAAN"] TO raan.
    SET MISSION_CONFIG["TARGET_ARG_OF_PERIAPSIS"] TO arg_pe.
    
    PRINT "Apoapsis set to: " + apo + " m".
    PRINT "Periapsis set to: " + peri + " m".
    PRINT "Inclination set to: " + inc + "°".
    PRINT "RAAN set to: " + raan + "°".
    PRINT "Arg of Periapsis set to: " + arg_pe + "°".
}

FUNCTION ConfigureGravityTurn {
    PRINT "Configure gravity turn:".
    
    LOCAL aggressiveness IS DEFAULTS["GRAVITY_TURN_AGGRESSIVENESS"].
    LOCAL waypoints IS DEFAULTS["GRAVITY_TURN_WAYPOINTS"].
    
    SET MISSION_CONFIG["GRAVITY_TURN_AGGRESSIVENESS"] TO aggressiveness.
    SET MISSION_CONFIG["GRAVITY_TURN_WAYPOINTS"] TO waypoints.
    
    PRINT "Aggressiveness: " + aggressiveness.
    PRINT "Waypoints: " + waypoints.
}

FUNCTION ConfigureStagingManifest {
    PRINT "Automatic staging enabled.".
    PRINT "Monitoring engines and delta-V for staging events.".
    SET MISSION_CONFIG["STAGING_MANIFEST"] TO LIST().
}

FUNCTION RunSetupWizard {
    ClearScreen.
    PRINT "=== KOS AUTOPILOT SETUP ===".
    PRINT "".
    
    ConfigureBodySelection().
    ConfigureOrbitParameters().
    ConfigureGravityTurn().
    ConfigureStagingManifest().
    
    LOCAL errors IS ValidateMissionConfig().
    IF errors:LENGTH > 0 {
        PRINT "Configuration errors:".
        FOR err IN errors {
            PRINT "  - " + err.
        }
        RETURN FALSE.
    }
    
    PRINT "".
    PRINT "Configuration complete and valid!".
    RETURN TRUE.
}
