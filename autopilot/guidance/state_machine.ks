GLOBAL GUIDANCE_STATE IS "INITIALIZATION".
GLOBAL PREVIOUS_STATE IS "".
GLOBAL STATE_ENTER_TIME IS TIME:SECONDS.

FUNCTION StateTransition {
    PARAMETER new_state.
    
    SET PREVIOUS_STATE TO GUIDANCE_STATE.
    SET GUIDANCE_STATE TO new_state.
    SET STATE_ENTER_TIME TO TIME:SECONDS.
    
    PRINT "State transition: " + PREVIOUS_STATE + " -> " + GUIDANCE_STATE.
}

FUNCTION UpdateState {
    IF CONTROL_STATE["ABORT_REQUESTED"] {
        IF GUIDANCE_STATE <> "DISENGAGED" {
            ExecuteAbort("Abort requested").
        }
        RETURN.
    }
    
    IF GUIDANCE_STATE = "INITIALIZATION" {
        StateTransition("PREFLIGHT_VALIDATION").
    }
    ELSE IF GUIDANCE_STATE = "PREFLIGHT_VALIDATION" {
        IF RunPreflightValidation() {
            StateTransition("WAITING_FOR_LAUNCH_WINDOW").
        } ELSE {
            StateTransition("DISENGAGED").
        }
    }
    ELSE IF GUIDANCE_STATE = "WAITING_FOR_LAUNCH_WINDOW" {
        IF CheckLaunchInput() {
            StateTransition("LAUNCH").
        }
    }
    ELSE IF GUIDANCE_STATE = "LAUNCH" {
        FROM {local x is 3.} UNTIL x = 0 STEP {set x to x-1.} DO {
            print "T - " + x.
            WAIT 1.
        }
        StateTransition("VERTICAL_ASCENT").
    }
    ELSE IF GUIDANCE_STATE = "VERTICAL_ASCENT" {
        IF SHIP:ALTITUDE >= MISSION_CONFIG["GRAVITY_TURN_START_ALTITUDE"] {
            StateTransition("GRAVITY_TURN").
        }
    }
    ELSE IF GUIDANCE_STATE = "GRAVITY_TURN" {
        IF SHIP:APOAPSIS >= MISSION_CONFIG["TARGET_APOAPSIS"] - DEFAULTS["COASTING_OVERSHOOT_MARGIN"] {
            StateTransition("APOAPSIS_TARGETING").
        }
    }
    ELSE IF GUIDANCE_STATE = "APOAPSIS_TARGETING" {
        IF SHIP:CONTROL:MAINTHROTTLE <= 0.01 {
            StateTransition("COAST_TO_APOAPSIS").
        }
    }
    ELSE IF GUIDANCE_STATE = "COAST_TO_APOAPSIS" {
        LOCAL time_to_apoapsis IS SHIP:ORBIT:ETA:APOAPSIS.
        IF time_to_apoapsis <= DEFAULTS["COAST_TO_APOAPSIS_THRESHOLD"] OR SHIP:APOAPSIS >= SHIP:ALTITUDE {
            StateTransition("ORBITAL_INSERTION").
        }
    }
    ELSE IF GUIDANCE_STATE = "ORBITAL_INSERTION" {
        IF ABS(SHIP:PERIAPSIS - MISSION_CONFIG["TARGET_PERIAPSIS"]) <= DEFAULTS["PERIAPSIS_TOLERANCE"] {
            StateTransition("ORBIT_CORRECTION").
        }
    }
    ELSE IF GUIDANCE_STATE = "ORBIT_CORRECTION" {
        IF IsOrbitValid() {
            StateTransition("MISSION_COMPLETE").
        }
    }
    ELSE IF GUIDANCE_STATE = "MISSION_COMPLETE" {
        IF TIME:SECONDS - STATE_ENTER_TIME >= DEFAULTS["MISSION_COMPLETE_DELAY"] {
            StateTransition("DISENGAGED").
        }
    }
}

FUNCTION IsOrbitValid {
    LOCAL apo_error IS ABS(SHIP:APOAPSIS - MISSION_CONFIG["TARGET_APOAPSIS"]).
    LOCAL peri_error IS ABS(SHIP:PERIAPSIS - MISSION_CONFIG["TARGET_PERIAPSIS"]).
    LOCAL inc_error IS ABS(SHIP:ORBIT:INCLINATION - MISSION_CONFIG["TARGET_INCLINATION"]).
    LOCAL raan_error IS ABS(SHIP:ORBIT:LONGAN - MISSION_CONFIG["TARGET_RAAN"]).
    LOCAL arg_error IS ABS(SHIP:ORBIT:ARGUMENTOFPERIAPSIS - MISSION_CONFIG["TARGET_ARG_OF_PERIAPSIS"]).
    
    RETURN apo_error <= DEFAULTS["APOAPSIS_TOLERANCE"] AND 
           peri_error <= DEFAULTS["PERIAPSIS_TOLERANCE"] AND 
           inc_error <= DEFAULTS["INCLINATION_TOLERANCE"] AND 
           raan_error <= DEFAULTS["RAAN_TOLERANCE"] AND 
           arg_error <= DEFAULTS["ARG_OF_PERIAPSIS_TOLERANCE"].
}
