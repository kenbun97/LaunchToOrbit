GLOBAL STAGING_STATE IS LEXICON(
    "CURRENT_STAGE", 0,
    "ACTIVE_ENGINES", LIST(),
    "PREVIOUS_ENGINE_COUNT", 0,
    "FLAMEOUT_CYCLES", 0,
    "LAUNCH_STAGED", FALSE
).

FUNCTION UpdateActiveEngines {
    SET STAGING_STATE["PREVIOUS_ENGINE_COUNT"] TO STAGING_STATE["ACTIVE_ENGINES"]:LENGTH.
    SET STAGING_STATE["ACTIVE_ENGINES"] TO LIST().
    
    FOR engine IN SHIP:ENGINES {
        IF engine:IGNITION {
            STAGING_STATE["ACTIVE_ENGINES"]:ADD(engine).
        }
    }
    
    SET STAGING_STATE["CURRENT_STAGE"] TO STAGE:NUMBER.
}

FUNCTION CheckStagingCondition {
    IF SHIP:STATUS = "PRELAUNCH"
       AND NOT STAGING_STATE["LAUNCH_STAGED"] {
        RETURN TRUE.
    }

    LOCAL current_stage_delta_v IS SHIP:DELTAV:CURRENT.
    LOCAL engines_flaming_out IS 0.
    LOCAL total_thrust IS 0.
    
    PRINT "STAGING CHECK".
    FOR engine IN STAGING_STATE["ACTIVE_ENGINES"] {
        IF engine:FLAMEOUT {
            SET engines_flaming_out TO engines_flaming_out + 1.
        }
        SET total_thrust TO total_thrust + engine:THRUST.
    }
    
    IF current_stage_delta_v <= DEFAULTS["STAGING_DELTA_V_TOLERANCE"] {
        RETURN TRUE.
    }
    
    IF engines_flaming_out > 0 AND engines_flaming_out >= STAGING_STATE["ACTIVE_ENGINES"]:LENGTH {
        SET STAGING_STATE["FLAMEOUT_CYCLES"] TO STAGING_STATE["FLAMEOUT_CYCLES"] + 1.
        
        IF STAGING_STATE["FLAMEOUT_CYCLES"] >= DEFAULTS["FLAMEOUT_CONFIRMATION_CYCLES"] {
            RETURN TRUE.
        }
    } ELSE {
        SET STAGING_STATE["FLAMEOUT_CYCLES"] TO 0.
    }
    
    RETURN FALSE.
}

FUNCTION ExecuteStaging {
    SET SHIP:CONTROL:MAINTHROTTLE TO 0.
    STAGE.
    SET STAGING_STATE["LAUNCH_STAGED"] TO TRUE.
    WAIT 0.1.
    
    UpdateActiveEngines().
    
    IF STAGING_STATE["ACTIVE_ENGINES"]:LENGTH > 0 {
        PRINT "Stage " + STAGING_STATE["CURRENT_STAGE"] + " active. Engines: " + STAGING_STATE["ACTIVE_ENGINES"]:LENGTH.
        RETURN TRUE.
    } ELSE {
        PRINT "ERROR: No active engines after staging!".
        RETURN FALSE.
    }
}

FUNCTION MonitorStaging {
    UpdateActiveEngines().
    
    IF CheckStagingCondition() {
        PRINT "Staging condition met. Executing stage...".
        RETURN ExecuteStaging().
    }
    
    RETURN FALSE.
}

FUNCTION GetStagingStatus {
    RETURN LEXICON(
        "CURRENT_STAGE", STAGING_STATE["CURRENT_STAGE"],
        "ACTIVE_ENGINE_COUNT", STAGING_STATE["ACTIVE_ENGINES"]:LENGTH,
        "STAGE_DELTA_V", SHIP:DELTAV:CURRENT,
        "TOTAL_THRUST", SHIP:THRUST
    ).
}
