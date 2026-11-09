GLOBAL TELEMETRY_DATA IS LEXICON(
    "LAST_SAMPLE_TIME", 0,
    "SAMPLE_INTERVAL", 0.1,
    "BUFFER", LIST()
).

FUNCTION InitTelemetrySystem {
    SET TELEMETRY_DATA["SAMPLE_INTERVAL"] TO 1.0 / DEFAULTS["LOOP_FREQUENCY"].
    SET TELEMETRY_DATA["BUFFER"] TO LIST().
    PRINT "Telemetry system initialized.".
}

FUNCTION CollectTelemetrySample {
    LOCAL current_time IS TIME:SECONDS.
    
    IF (current_time - TELEMETRY_DATA["LAST_SAMPLE_TIME"]) < TELEMETRY_DATA["SAMPLE_INTERVAL"] {
        RETURN FALSE.
    }
    
    SET TELEMETRY_DATA["LAST_SAMPLE_TIME"] TO current_time.
    LOCAL velocity_vector IS SHIP:VELOCITY:ORBIT.
    LOCAL measured_pitch IS ARCSIN(MAX(-1, MIN(1, VDOT(SHIP:FACING:FOREVECTOR, SHIP:UP:VECTOR)))).
    // Calculate horizon-relative roll.
    // At a vertical attitude, horizon-relative roll is undefined.
    LOCAL forward_vector IS SHIP:FACING:FOREVECTOR.
    LOCAL top_vector IS SHIP:FACING:TOPVECTOR.
    LOCAL right_vector IS SHIP:FACING:STARVECTOR.
    LOCAL local_up IS SHIP:UP:VECTOR.

    LOCAL projected_up IS local_up
        - forward_vector * VDOT(local_up, forward_vector).

    LOCAL measured_roll IS -999.

    IF projected_up:MAG > 0.000001 {
        SET measured_roll TO ARCTAN2(
            VDOT(right_vector, projected_up),
            VDOT(top_vector, projected_up)
        ).
    }

    // Count engines currently producing thrust.
    LOCAL engines IS LIST().
    LIST ENGINES IN engines.

    LOCAL active_engine_count IS 0.
    FOR engine IN engines {
        IF engine:THRUST > 0 {
            SET active_engine_count TO active_engine_count + 1.
        }
    }

    // Stock KSP: atmosphere rotates with the surface and has no wind.
    LOCAL air_speed IS SHIP:VELOCITY:SURFACE:MAG.
    LOCAL dynamic_pressure_pa IS SHIP:Q * 101325.

    // Infer density from q = 0.5 * rho * v^2.
    // At zero speed, q cannot tell us the density: use -1 as "unknown".
    LOCAL air_density IS -1.
    IF air_speed > 0.001 {
        SET air_density TO 2 * dynamic_pressure_pa / (air_speed ^ 2).
    }

    LOCAL total_thrust IS SHIP:THRUST.
    LOCAL approximate_thrust_vector IS forward_vector * total_thrust.


    LOCAL sample IS LEXICON(
        "UT", current_time,
        "MET", MISSIONTIME,
        "VESSEL_NAME", SHIP:NAME,
        "GUIDANCE_STATE", GUIDANCE_STATE,
        "WAYPOINT_INDEX", CURRENT_WAYPOINT_INDEX,
        "ALTITUDE", SHIP:ALTITUDE,
        "LATITUDE", SHIP:GEOPOSITION:LAT,
        "LONGITUDE", SHIP:GEOPOSITION:LNG,
        "POSITION_X", SHIP:POSITION:X,
        "POSITION_Y", SHIP:POSITION:Y,
        "POSITION_Z", SHIP:POSITION:Z,
        "VELOCITY", velocity_vector:MAG,
        "VELOCITY_X", velocity_vector:X,
        "VELOCITY_Y", velocity_vector:Y,
        "VELOCITY_Z", velocity_vector:Z,
        "VERTICAL_VELOCITY", SHIP:VERTICALSPEED,
        "TARGET_HEADING", TARGET_HEADING,
        "MEASURED_HEADING", SHIP:HEADING,
        "TARGET_PITCH", TARGET_PITCH,
        "MEASURED_PITCH", measured_pitch,
        "TARGET_ROLL", TARGET_ROLL,
        "MEASURED_ROLL", measured_roll,
        "THROTTLE_COMMAND", SHIP:CONTROL:MAINTHROTTLE,
        "THROTTLE_ACTUAL", SHIP:CONTROL:MAINTHROTTLE,
        "TOTAL_THRUST", total_thrust,
        "THRUST_X", approximate_thrust_vector:X,
        "THRUST_Y", approximate_thrust_vector:Y,
        "THRUST_Z", approximate_thrust_vector:Z,
        "VESSEL_MASS", SHIP:MASS,
        "CURRENT_STAGE", STAGE:NUMBER,
        "ACTIVE_ENGINE_COUNT", active_engine_count,
        "STAGE_DELTA_V", STAGE:DELTAV:CURRENT,
        "APOAPSIS", SHIP:APOAPSIS,
        "PERIAPSIS", SHIP:PERIAPSIS,
        "SEMIMAJOR_AXIS", SHIP:ORBIT:SEMIMAJORAXIS,
        "ECCENTRICITY", SHIP:ORBIT:ECCENTRICITY,
        "INCLINATION", SHIP:ORBIT:INCLINATION,
        "RAAN", SHIP:ORBIT:LAN,
        "ARG_OF_PERIAPSIS", SHIP:ORBIT:ARGUMENTOFPERIAPSIS,
        "ORBITAL_PERIOD", SHIP:ORBIT:PERIOD,
        "AIR_DENSITY", air_density,
        "AIR_RELATIVE_VELOCITY", air_speed,
        "DYNAMIC_PRESSURE", dynamic_pressure_pa,
        "GRAVITY_MAGNITUDE", SHIP:BODY:MU
            / ((SHIP:ALTITUDE + SHIP:BODY:RADIUS) ^ 2)
    ).
    
    TELEMETRY_DATA["BUFFER"]:ADD(sample).
    RETURN TRUE.
}

FUNCTION GetTelemetryBuffer {
    RETURN TELEMETRY_DATA["BUFFER"].
}

FUNCTION ClearTelemetryBuffer {
    SET TELEMETRY_DATA["BUFFER"] TO LIST().
}
