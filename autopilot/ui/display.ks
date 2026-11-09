GLOBAL DISPLAY_STATE IS "PRELAUNCH".

FUNCTION DisplayPrelaunchScreen {
    ClearScreen.
    PRINT "=== KOS AUTOPILOT - PRELAUNCH ===".
    PRINT "".
    PRINT "Target Body: " + MISSION_CONFIG["BODY"]:NAME.
    PRINT "Target Apoapsis: " + MISSION_CONFIG["TARGET_APOAPSIS"] + " m".
    PRINT "Target Periapsis: " + MISSION_CONFIG["TARGET_PERIAPSIS"] + " m".
    PRINT "Target Inclination: " + MISSION_CONFIG["TARGET_INCLINATION"] + "°".
    PRINT "Target RAAN: " + MISSION_CONFIG["TARGET_RAAN"] + "°".
    PRINT "Target Arg of Periapsis: " + MISSION_CONFIG["TARGET_ARG_OF_PERIAPSIS"] + "°".
    PRINT "".
    PRINT "Gravity Turn Aggressiveness: " + MISSION_CONFIG["GRAVITY_TURN_AGGRESSIVENESS"].
    PRINT "Gravity Turn Waypoints: " + MISSION_CONFIG["GRAVITY_TURN_WAYPOINTS"].
    PRINT "".
    PRINT "Launch Site Latitude: " + ROUND(MISSION_CONFIG["LAUNCH_SITE_LATITUDE"], 2) + "°".
    PRINT "Launch Site Longitude: " + ROUND(MISSION_CONFIG["LAUNCH_SITE_LONGITUDE"], 2) + "°".
    PRINT "".
    PRINT "AG10 set for abort: Check manual".
    PRINT "".
    PRINT "[READY] to proceed, [ABORT] to cancel".
}

FUNCTION DisplayFlightScreen {
    SET DISPLAY_STATE TO "FLIGHT".
    ClearScreen.
    PRINT "=== KOS AUTOPILOT - FLIGHT ===".
    PRINT "Time: " + TIME:SECONDS.
    PRINT "State: " + GUIDANCE_STATE.
    PRINT "Altitude: " + ROUND(SHIP:ALTITUDE, 1) + " m".
    PRINT "Velocity: " + ROUND(SHIP:VELOCITY:MAG, 1) + " m/s".
    PRINT "Apoapsis: " + ROUND(SHIP:APOAPSIS, 1) + " m".
    PRINT "Periapsis: " + ROUND(SHIP:PERIAPSIS, 1) + " m".
}

FUNCTION DisplayAbortScreen {
    SET DISPLAY_STATE TO "ABORT".
    ClearScreen.
    PRINT "=== ABORT IN PROGRESS ===".
    PRINT "Disengaging autopilot...".
    PRINT "Flushing telemetry...".
}

FUNCTION UpdateTelemetryDisplay {
    PARAMETER current_altitude, current_velocity, _apoapsis, _periapsis, state.
    
    PRINT "".
    PRINT "ALT: " + ROUND(current_altitude, 0) + " m | VEL: " + ROUND(current_velocity, 1) + " m/s | AP: " + ROUND(_apoapsis, 0) + " m | PE: " + ROUND(_periapsis, 0) + " m | STATE: " + state.
}
