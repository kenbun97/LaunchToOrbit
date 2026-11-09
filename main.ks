CLEARSCREEN.
RUNPATH("autopilot/config/defaults.ks").
RUNPATH("autopilot/config/mission_config.ks").
RUNPATH("autopilot/ui/display.ks").
RUNPATH("autopilot/ui/setup.ks").
RUNPATH("autopilot/ui/controls.ks").
RUNPATH("autopilot/telemetry/collect.ks").
RUNPATH("autopilot/telemetry/logging.ks").
RUNPATH("autopilot/telemetry/forces.ks").
RUNPATH("autopilot/safety/validation.ks").
RUNPATH("autopilot/safety/abort.ks").
RUNPATH("autopilot/guidance/state_machine.ks").
RUNPATH("autopilot/guidance/mission.ks").
RUNPATH("autopilot/guidance/launch_window.ks").
RUNPATH("autopilot/guidance/trajectory.ks").
RUNPATH("autopilot/guidance/orbital_guidance.ks").
RUNPATH("autopilot/control/attitude.ks").
RUNPATH("autopilot/control/steering.ks").
RUNPATH("autopilot/control/throttle.ks").
RUNPATH("autopilot/staging/manifest.ks").
RUNPATH("autopilot/staging/manager.ks").
RUNPATH("autopilot/utilities/vectors.ks").
RUNPATH("autopilot/utilities/orbital_math.ks").
RUNPATH("autopilot/utilities/interpolation.ks").

PRINT "=== KOS AUTOPILOT INITIALIZATION ===".
PRINT "".

InitializeMissionConfig().
InitTelemetrySystem().
BindAbortSystem().
CreateTelemetryFile().

IF NOT RunSetupWizard() {
    PRINT "Setup failed. Aborting.".
    SET GUIDANCE_STATE TO "DISENGAGED".
}

GenerateGravityTurnWaypoints().
UpdateActiveEngines().

DisplayPrelaunchScreen().

PRINT "".
PRINT "Preflight validation...".
IF NOT RunPreflightValidation() {
    PRINT "Preflight validation failed!".
    SET GUIDANCE_STATE TO "DISENGAGED".
}

PRINT "".
PRINT "Ready for launch. Engage throttle to launch.".

SET LOOP_START_TIME TO TIME:SECONDS.
LOCAL loop_count IS 0.

UNTIL GUIDANCE_STATE = "DISENGAGED" {
    LOCAL loop_time_start IS TIME:SECONDS.
    
    ClearControlRequests().
    UpdateState().
    
    IF GUIDANCE_STATE = "PREFLIGHT_VALIDATION" {
        WAIT 0.1.
    }
    ELSE IF GUIDANCE_STATE = "WAITING_FOR_LAUNCH_WINDOW" {
        CheckLaunchInput().
        WAIT 0.1.
    }
    ELSE IF GUIDANCE_STATE = "LAUNCH" {
        ExecuteVerticalAscent().
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "VERTICAL_ASCENT" {
        ExecuteVerticalAscent().
        MonitorStaging().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "GRAVITY_TURN" {
        LOCAL desired_pitch IS InterpolateGravityTurn(SHIP:ALTITUDE).
        SET TARGET_PITCH TO 90 - desired_pitch.
        ExecuteGravityTurn().
        MonitorStaging().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "APOAPSIS_TARGETING" {
        ExecuteApoapsisTargeting().
        MonitorStaging().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "COAST_TO_APOAPSIS" {
        ExecuteCoastToApoapsis().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "ORBITAL_INSERTION" {
        ExecuteOrbitalInsertion().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "ORBIT_CORRECTION" {
        ExecuteOrbitCorrection().
        CollectTelemetrySample().
        UpdateTelemetryDisplay(SHIP:ALTITUDE, SHIP:VELOCITY:ORBIT:MAG, SHIP:APOAPSIS, SHIP:PERIAPSIS, GUIDANCE_STATE).
        WAIT 0.01.
    }
    ELSE IF GUIDANCE_STATE = "MISSION_COMPLETE" {
        ExecuteMissionComplete().
        WriteTelemetryBuffer().
        CollectTelemetrySample().
        WAIT 0.1.
    }
    ELSE IF GUIDANCE_STATE = "ABORTING" {
        DisplayAbortScreen().
        WAIT 0.1.
    }
    ELSE IF GUIDANCE_STATE = "DISENGAGED" {
        CloseTelemetryFile().
        PRINT "Autopilot disengaged.".
        BREAK.
    }
    
    LOCAL loop_time_end IS TIME:SECONDS.
    LOCAL loop_duration IS loop_time_end - loop_time_start.
    LOCAL target_interval IS 1.0 / DEFAULTS["LOOP_FREQUENCY"].
    
    IF loop_duration < target_interval {
        WAIT (target_interval - loop_duration).
    }
    
    SET loop_count TO loop_count + 1.
}

PRINT "".
PRINT "=== AUTOPILOT TERMINATED ===".
