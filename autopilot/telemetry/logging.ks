GLOBAL TELEMETRY_FILE IS 0.
GLOBAL TELEMETRY_FILENAME IS "".

FUNCTION PadTwoDigits {
    PARAMETER number.

    LOCAL whole IS FLOOR(number).

    IF whole < 10 {
        RETURN "0" + whole.
    }

    RETURN "" + whole.
}

FUNCTION CreateTelemetryFile {
    // Capture the time once so all fields use the same timestamp.
    LOCAL stamp IS TIME.

    SET TELEMETRY_FILENAME TO "/logs/"
        + MISSION_CONFIG["VESSEL_NAME"]
        + "_Y" + stamp:YEAR
        + "_D" + stamp:DAY
        + "_" + PadTwoDigits(stamp:HOUR)
        + "-" + PadTwoDigits(stamp:MINUTE)
        + "-" + PadTwoDigits(stamp:SECOND)
        + "_1.csv".

    LOCAL header IS "UT,MET,VESSEL_NAME,GUIDANCE_STATE,WAYPOINT_INDEX,ALTITUDE,LATITUDE,LONGITUDE,POSITION_X,POSITION_Y,POSITION_Z,VELOCITY,VELOCITY_X,VELOCITY_Y,VELOCITY_Z,VERTICAL_VELOCITY,TARGET_HEADING,MEASURED_HEADING,TARGET_PITCH,MEASURED_PITCH,TARGET_ROLL,MEASURED_ROLL,THROTTLE_COMMAND,THROTTLE_ACTUAL,TOTAL_THRUST,THRUST_X,THRUST_Y,THRUST_Z,VESSEL_MASS,CURRENT_STAGE,ACTIVE_ENGINE_COUNT,STAGE_DELTA_V,APOAPSIS,PERIAPSIS,SEMIMAJOR_AXIS,ECCENTRICITY,INCLINATION,RAAN,ARG_OF_PERIAPSIS,ORBITAL_PERIOD,AIR_DENSITY,AIR_RELATIVE_VELOCITY,DYNAMIC_PRESSURE,GRAVITY_MAGNITUDE".

    LOG header TO TELEMETRY_FILENAME.

    PRINT "Telemetry file created: " + TELEMETRY_FILENAME.
}


FUNCTION WriteTelemetryBuffer {
    IF TELEMETRY_FILE = 0 {
        RETURN.
    }
    
    LOCAL buffer IS GetTelemetryBuffer().
    
    FOR sample IN buffer {
        LOCAL line IS sample["UT"] + "," + sample["MET"] + "," + sample["VESSEL_NAME"] + "," + sample["GUIDANCE_STATE"] + "," + sample["WAYPOINT_INDEX"].
        
        SET line TO line + "," + sample["ALTITUDE"] + "," + sample["LATITUDE"] + "," + sample["LONGITUDE"].
        SET line TO line + "," + sample["POSITION_X"] + "," + sample["POSITION_Y"] + "," + sample["POSITION_Z"].
        SET line TO line + "," + sample["VELOCITY"] + "," + sample["VELOCITY_X"] + "," + sample["VELOCITY_Y"] + "," + sample["VELOCITY_Z"].
        SET line TO line + "," + sample["VERTICAL_VELOCITY"].
        SET line TO line + "," + sample["TARGET_HEADING"] + "," + sample["MEASURED_HEADING"].
        SET line TO line + "," + sample["TARGET_PITCH"] + "," + sample["MEASURED_PITCH"].
        SET line TO line + "," + sample["TARGET_ROLL"] + "," + sample["MEASURED_ROLL"].
        SET line TO line + "," + sample["THROTTLE_COMMAND"] + "," + sample["THROTTLE_ACTUAL"].
        SET line TO line + "," + sample["TOTAL_THRUST"] + "," + sample["THRUST_X"] + "," + sample["THRUST_Y"] + "," + sample["THRUST_Z"].
        SET line TO line + "," + sample["VESSEL_MASS"] + "," + sample["CURRENT_STAGE"] + "," + sample["ACTIVE_ENGINE_COUNT"].
        SET line TO line + "," + sample["STAGE_DELTA_V"] + "," + sample["APOAPSIS"] + "," + sample["PERIAPSIS"].
        SET line TO line + "," + sample["SEMIMAJOR_AXIS"] + "," + sample["ECCENTRICITY"].
        SET line TO line + "," + sample["INCLINATION"] + "," + sample["RAAN"] + "," + sample["ARG_OF_PERIAPSIS"].
        SET line TO line + "," + sample["ORBITAL_PERIOD"].
        SET line TO line + "," + sample["AIR_DENSITY"] + "," + sample["AIR_RELATIVE_VELOCITY"] + "," + sample["DYNAMIC_PRESSURE"].
        SET line TO line + "," + sample["GRAVITY_MAGNITUDE"].
        
        TELEMETRY_FILE:WRITELN(line).
    }
    
    ClearTelemetryBuffer().
}

FUNCTION CloseTelemetryFile {
    IF TELEMETRY_FILE <> 0 {
        WriteTelemetryBuffer().
        TELEMETRY_FILE:CLOSE().
        SET TELEMETRY_FILE TO 0.
        PRINT "Telemetry file closed.".
    }
}
