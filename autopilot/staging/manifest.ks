GLOBAL STAGING_MANIFEST IS LIST().

FUNCTION CreateStagingEvent {
    PARAMETER event_id, stage_type, engines, decouplers.
    
    LOCAL event IS LEXICON(
        "ID", event_id,
        "TYPE", stage_type,
        "ENGINES", engines,
        "DECOUPLERS", decouplers,
        "EXHAUSTION_CRITERIA", "DELTA_V",
        "EXHAUSTION_THRESHOLD", DEFAULTS["STAGING_DELTA_V_TOLERANCE"],
        "DECOUPLER_TIMEOUT", DEFAULTS["DECOUPLER_TIMEOUT"],
        "EXECUTED", FALSE,
        "TIMESTAMP", 0
    ).
    
    STAGING_MANIFEST:ADD(event).
    RETURN event.
}

FUNCTION ValidateStagingManifest {
    IF STAGING_MANIFEST:LENGTH = 0 {
        PRINT "No explicit staging manifest. Using automatic staging.".
        RETURN TRUE.
    }
    
    FOR event IN STAGING_MANIFEST {
        IF event["ENGINES"]:LENGTH = 0 {
            PRINT "ERROR: Staging event " + event["ID"] + " has no engines.".
            RETURN FALSE.
        }
    }
    
    RETURN TRUE.
}

FUNCTION GetNextStagingEvent {
    FOR event IN STAGING_MANIFEST {
        IF NOT event["EXECUTED"] {
            RETURN event.
        }
    }
    RETURN 0.
}

FUNCTION MarkStagingEventExecuted {
    PARAMETER event_id.
    
    FOR event IN STAGING_MANIFEST {
        IF event["ID"] = event_id {
            SET event["EXECUTED"] TO TRUE.
            SET event["TIMESTAMP"] TO TIME:SECONDS.
            RETURN TRUE.
        }
    }
    RETURN FALSE.
}
