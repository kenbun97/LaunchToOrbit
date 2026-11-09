GLOBAL SENSOR_STATUS IS LEXICON(
    "ACCELEROMETER_PRESENT", FALSE,
    "GRAVIOLI_DETECTOR_PRESENT", FALSE,
    "ALL_VALID", FALSE
).

FUNCTION ValidateAccelerometer {
    FOR part IN SHIP:PARTS {
        IF part:NAME:CONTAINS("accelerometer") OR part:NAME:CONTAINS("linear") {
            SET SENSOR_STATUS["ACCELEROMETER_PRESENT"] TO TRUE.
            PRINT "Accelerometer found: " + part:NAME.
            RETURN TRUE.
        }
    }
    PRINT "ERROR: Accelerometer not found!".
    RETURN FALSE.
}

FUNCTION ValidateGravioliDetector {
    FOR part IN SHIP:PARTS {
        IF part:NAME:CONTAINS("gravioli") OR part:NAME:CONTAINS("Gravimeter") {
            SET SENSOR_STATUS["GRAVIOLI_DETECTOR_PRESENT"] TO TRUE.
            PRINT "Gravioli Detector found: " + part:NAME.
            RETURN TRUE.
        }
    }
    PRINT "ERROR: Gravioli Detector not found!".
    RETURN FALSE.
}

FUNCTION ValidateSensors {
    PRINT "Validating sensors...".
    
    LOCAL acc_valid IS ValidateAccelerometer().
    LOCAL grav_valid IS ValidateGravioliDetector().
    
    IF acc_valid AND grav_valid {
        SET SENSOR_STATUS["ALL_VALID"] TO TRUE.
        PRINT "All sensors validated successfully.".
        RETURN TRUE.
    }
    
    PRINT "Sensor validation failed.".
    RETURN FALSE.
}

FUNCTION RunPreflightValidation {
    PRINT "Running preflight validation...".
    
    IF NOT ValidateSensors() {
        PRINT "PREFLIGHT VALIDATION FAILED!".
        RETURN FALSE.
    }
    
    LOCAL config_errors IS ValidateMissionConfig().
    IF config_errors:LENGTH > 0 {
        PRINT "Configuration errors:".
        FOR err IN config_errors {
            PRINT "  - " + err.
        }
        RETURN FALSE.
    }
    
    IF SHIP:ENGINES:LENGTH = 0 {
        PRINT "ERROR: No engines found on vessel!".
        RETURN FALSE.
    }
    
    PRINT "Preflight validation complete. Ready to launch.".
    RETURN TRUE.
}
