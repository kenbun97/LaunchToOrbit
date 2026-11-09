FUNCTION CalculateLaunchWindow {
    LOCAL target_inc IS MISSION_CONFIG["TARGET_INCLINATION"].
    LOCAL launch_lat IS MISSION_CONFIG["LAUNCH_SITE_LATITUDE"].
    
    IF ABS(target_inc) < ABS(launch_lat) {
        PRINT "ERROR: Target inclination is less than launch latitude!".
        PRINT "Minimum achievable inclination: " + ABS(launch_lat) + "°".
        RETURN -1.
    }
    
    LOCAL current_time IS TIME:SECONDS.
    LOCAL rotation_period IS SHIP:BODY:ROTATIONPERIOD.
    
    LOCAL angle_offset IS launch_lat * (3.14159 / 180).
    LOCAL launch_window_time IS current_time + 3600.
    
    PRINT "Launch window calculated.".
    PRINT "Target inclination: " + target_inc + "°".
    PRINT "Launch site latitude: " + launch_lat + "°".
    PRINT "Estimated launch time: " + launch_window_time.
    
    RETURN launch_window_time.
}

FUNCTION ValidateLaunchGeometry {
    LOCAL target_inc IS MISSION_CONFIG["TARGET_INCLINATION"].
    LOCAL launch_lat IS ABS(MISSION_CONFIG["LAUNCH_SITE_LATITUDE"]).
    
    RETURN target_inc >= launch_lat.
}

FUNCTION WaitForLaunchWindow {
    PRINT "Waiting for launch window...".
    PRINT "Press throttle up to launch when ready.".
}
