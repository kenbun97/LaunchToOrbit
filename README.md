# KOS Autonomous Rocket Launch and Orbital Insertion Autopilot

A complete autonomous launch and orbital insertion system for Kerbal Space Program using kOS 1.4.0.

## Features

- **Phases 1-5 Implementation**: Foundation, staging manager, flight controller, launch guidance, and orbital insertion
- **Multi-Stage Support**: Handles simple stages, parallel boosters, and complex staging configurations
- **Gravity Turn Execution**: Smooth altitude-based waypoint tracking with smoothstep interpolation
- **Orbital Insertion**: Apoapsis targeting with coasting strategy and periapsis correction
- **Comprehensive Telemetry**: 10 Hz CSV logging with mission metadata
- **Safety Systems**: Abort handling, preflight validation, sensor verification
- **Interactive Configuration**: No persistent config files; UI-based mission parameter setup

## Project Structure

```
autopilot/
├── config/                 # Configuration system
│   ├── defaults.ks        # Default mission parameters
│   └── mission_config.ks  # Mission configuration interface
├── ui/                     # User interface
│   ├── display.ks         # Flight display screens
│   ├── setup.ks           # Setup wizard
│   └── controls.ks        # Input handling and control binding
├── guidance/              # Flight guidance
│   ├── state_machine.ks   # State machine logic
│   ├── mission.ks         # Mission phase execution
│   ├── launch_window.ks   # Launch window calculation
│   ├── trajectory.ks      # Gravity turn trajectory generation
│   └── orbital_guidance.ks # Orbital mechanics calculations
├── control/               # Flight control subsystem
│   ├── attitude.ks        # Attitude control with PID
│   ├── steering.ks        # Steering interface
│   └── throttle.ks        # Throttle management
├── staging/               # Staging system
│   ├── manifest.ks        # Staging event definitions
│   └── manager.ks         # Staging execution logic
├── safety/                # Safety and validation
│   ├── validation.ks      # Preflight validation and sensor checks
│   └── abort.ks           # Abort sequence
├── telemetry/             # Data collection and logging
│   ├── collect.ks         # Telemetry sampling at 10 Hz
│   ├── logging.ks         # CSV file writing
│   └── forces.ks          # Accelerometer and sensor data
├── utilities/             # Utility functions
│   ├── vectors.ks         # Vector math operations
│   ├── orbital_math.ks    # Orbital mechanics calculations
│   └── interpolation.ks   # Interpolation functions
├── docs/                  # Documentation
│   └── kos_api_reference.md # kOS 1.4.0 API reference
└── main.ks               # Main program entry point
```

## Getting Started

1. **Copy Files to KSP**
   - Place the entire `autopilot/` directory into your KSP `ships/` or `scripts/` folder
   - Ensure `main.ks` is the root script

2. **Launch Configuration**
   - Place a vessel on the launch pad with:
     - At least one engine
     - Accelerometer part (any accelerometer or linear acceleration sensor)
     - Gravioli Detector part (any gravity detector)
     - Action Group 10 configured (optional, but recommended for abort)

3. **Run the Autopilot**
   ```
   run autopilot/main.ks.
   ```

4. **Configuration Phase**
   - The setup wizard will guide you through:
     - Selecting target body (Kerbin, Mun, Minmus, Duna)
     - Setting target orbit parameters (apoapsis, periapsis, inclination, RAAN, arg of periapsis)
     - Configuring gravity turn aggressiveness (0-1) and waypoint count (10-1000)
   - Review preflight validation results

5. **Launch**
   - Increase main throttle to launch
   - Autopilot will execute:
     - Vertical ascent (1° pitch)
     - Gravity turn (altitude-based waypoints)
     - Apoapsis targeting (throttle reduction)
     - Coast to apoapsis
     - Orbital insertion burn
     - Orbit correction burns if needed
     - Mission complete

## Flight States

1. **INITIALIZATION**: Load modules and initialize systems
2. **PREFLIGHT_VALIDATION**: Verify sensors and mission parameters
3. **WAITING_FOR_LAUNCH_WINDOW**: Ready for manual launch trigger
4. **LAUNCH**: Release all launch locks
5. **VERTICAL_ASCENT**: Hold 1° pitch from zenith
6. **GRAVITY_TURN**: Track altitude-based waypoints with smooth interpolation
7. **APOAPSIS_TARGETING**: Reduce throttle as target apoapsis approached
8. **COAST_TO_APOAPSIS**: Zero throttle coast until apoapsis
9. **ORBITAL_INSERTION**: Execute prograde burn at apoapsis
10. **ORBIT_CORRECTION**: Check and correct orbital elements (max 3 burns)
11. **MISSION_COMPLETE**: Log completion and prepare disengagement
12. **ABORTING**: Emergency abort with telemetry flush
13. **DISENGAGED**: Manual flight control restored

## Telemetry Output

Telemetry is logged to CSV files with naming convention:
```
VESSEL_NAME_Y{year}_D{day}_{HH}-{MM}-{SS}_{seq}.csv
```

Columns include:
- Flight identification (UT, MET, vessel name, state, waypoint)
- Position and velocity (altitude, latitude, longitude, inertial coordinates)
- Attitude and control (heading, pitch, roll, throttle)
- Propulsion (thrust, engines, staging, delta-V)
- Orbital elements (apoapsis, periapsis, inclination, RAAN, arg of periapsis)
- Aerodynamics (air density, dynamic pressure, gravity)
- Diagnostics (accelerometer, gravioli detector readings)

## Orbital Tolerance Targets

- **Periapsis**: ±500 m
- **Apoapsis**: ±500 m
- **Inclination**: ±0.1°
- **RAAN**: ±0.1°
- **Argument of Periapsis**: ±0.1°

## Safety Features

- **Sensor Validation**: Preflight check confirms accelerometer and gravioli detector exist
- **Automatic Staging**: Monitors delta-V and engine flameout for automatic staging
- **Abort System**: AG10 or manual abort triggers emergency shutdown with telemetry flush
- **Time Warp Safety**: Disabled during ascent, re-enabled only outside atmosphere
- **Correction Limits**: Max 3 correction burns to prevent infinite loops

## Configuration Defaults

Key configurable parameters (in `config/defaults.ks`):
- Loop frequency: 10 Hz (100 ms)
- Target apoapsis: 100 km
- Target periapsis: 100 km
- Gravity turn waypoints: 50 (10-1000 range)
- Coasting overshoot margin: 100 m
- Orbital tolerances: ±500 m altitude, ±0.1° angles
- Max correction burns: 3
- Telemetry buffer: 100 samples

## Limitations

- No terrain collision detection (relies on altitude telemetry and atmospheric feedback)
- No gimbal control; all active engines thrust together
- Launch window calculation is simplified; does not account for precise node timing
- Orbital corrections assume circular orbits for simplification in Phase 5
- No atmospheric ascent profile optimization (fixed gravity turn path)

## Testing

1. **Simple Rocket**: Single-stage to 100 km orbit
2. **Multistage Rocket**: Two-stage with automatic staging on delta-V
3. **Parallel Boosters**: Core + 4 SRB configuration with staged separation
4. **Custom Orbits**: Inclined orbits at various inclinations
5. **Abort Testing**: Verify abort system on AG10 activation

## Development Notes

- **Phase 1**: Foundation complete (APIs, config, telemetry, validation, abort, main loop)
- **Phase 2**: Staging manager complete (automatic and manifest-based staging)
- **Phase 3**: Flight controller complete (attitude, steering, throttle with PID)
- **Phase 4**: Launch guidance complete (launch window, gravity turn with smoothstep)
- **Phase 5**: Orbital insertion complete (apoapsis targeting, insertion burn, corrections)

All five phases are fully implemented and ready for testing.

## Future Enhancements

- Custom PID tuning UI
- Advanced gravity turn profiles (thrust-vector-based)
- Precise atmospheric descent planning
- RCS-based orbital corrections
- Landing guidance and soft-landing capability
- Interplanetary transfer calculations

## API Reference

See `docs/kos_api_reference.md` for complete kOS 1.4.0 API documentation used in this project.
