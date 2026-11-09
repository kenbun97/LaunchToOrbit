GLOBAL GRAVITY_TURN_WAYPOINTS IS LIST().

FUNCTION GenerateGravityTurnWaypoints {
    LOCAL start_alt IS MISSION_CONFIG["GRAVITY_TURN_START_ALTITUDE"].
    LOCAL target_alt IS MISSION_CONFIG["TARGET_APOAPSIS"].
    LOCAL waypoint_count IS MISSION_CONFIG["GRAVITY_TURN_WAYPOINTS"].
    LOCAL aggressiveness IS MISSION_CONFIG["GRAVITY_TURN_AGGRESSIVENESS"].
    
    SET GRAVITY_TURN_WAYPOINTS TO LIST().
    
    FOR i IN RANGE(0, waypoint_count) {
        LOCAL _alt IS start_alt + (target_alt - start_alt) * (i / (waypoint_count - 1)).
        LOCAL pitch IS 90 - (90 * (i / (waypoint_count - 1))).
        
        GRAVITY_TURN_WAYPOINTS:ADD(LEXICON(
            "INDEX", i,
            "ALTITUDE", _alt,
            "PITCH", pitch
        )).
    }
    
    PRINT "Generated " + waypoint_count + " gravity turn waypoints.".
}

FUNCTION InterpolateGravityTurn {
    PARAMETER current_altitude.
    
    IF GRAVITY_TURN_WAYPOINTS:LENGTH = 0 {
        GenerateGravityTurnWaypoints().
    }
    
    FOR i IN RANGE(0, GRAVITY_TURN_WAYPOINTS:LENGTH - 1) {
        LOCAL wp1 IS GRAVITY_TURN_WAYPOINTS[i].
        LOCAL wp2 IS GRAVITY_TURN_WAYPOINTS[i + 1].
        
        IF current_altitude >= wp1["ALTITUDE"] AND current_altitude <= wp2["ALTITUDE"] {
            LOCAL t IS (current_altitude - wp1["ALTITUDE"]) / (wp2["ALTITUDE"] - wp1["ALTITUDE"]).
            LOCAL smoothstep IS 10 * (t ^ 3) - 15 * (t ^ 4) + 6 * (t ^ 5).
            LOCAL pitch IS wp1["PITCH"] + (wp2["PITCH"] - wp1["PITCH"]) * smoothstep.
            
            SET CURRENT_WAYPOINT_INDEX TO i.
            RETURN pitch.
        }
    }
    
    RETURN 0.
}

FUNCTION GetNextWaypoint {
    IF CURRENT_WAYPOINT_INDEX < GRAVITY_TURN_WAYPOINTS:LENGTH {
        RETURN GRAVITY_TURN_WAYPOINTS[CURRENT_WAYPOINT_INDEX].
    }
    RETURN GRAVITY_TURN_WAYPOINTS[GRAVITY_TURN_WAYPOINTS:LENGTH - 1].
}
