# KOS 1.4.0 API Reference for Autopilot

## Core Vessel Information

### SHIP Object
- **SHIP:NAME** - Vessel name (string)
- **SHIP:ALTITUDE** - Current altitude above sea level (meters)
- **SHIP:VELOCITY** - Current velocity vector (vector)
- **SHIP:VELOCITY:MAG** - Velocity magnitude (m/s)
- **SHIP:POSITION** - Position in inertial frame (vector)
- **SHIP:HEADING** - Current heading (degrees, 0-360)
- **SHIP:PITCH** - Current pitch (degrees, -90 to 90)
- **SHIP:ROLL** - Current roll (degrees, -180 to 180)
- **SHIP:VERTICALSPEED** - Vertical velocity (m/s, positive = up)
- **SHIP:AIRSPEED** - Velocity relative to atmosphere (m/s)
- **SHIP:GEOPOSITION** - Geographic position with LAT and LNG (degrees)
- **SHIP:BODY** - Reference to current body
- **SHIP:MASS** - Current vessel mass (kg)
- **SHIP:THRUST** - Current total thrust (kN)
- **SHIP:MAXTHRUST** - Maximum available thrust (kN)
- **SHIP:Q** - Dynamic pressure (kg/m³)
- **SHIP:PARTS** - List of all vessel parts
- **SHIP:ENGINES** - List of all engines
- **SHIP:DELTAV** - Delta-V information
- **SHIP:DELTAV:CURRENT** - Current stage delta-V (m/s)
- **SHIP:APOAPSIS** - Current apoapsis altitude (meters)
- **SHIP:PERIAPSIS** - Current periapsis altitude (meters)
- **SHIP:ANGULARVEL** - Angular velocity vector (rad/s)

## Orbital Information

### SHIP:ORBIT Object
- **SHIP:ORBIT:INCLINATION** - Orbital inclination (degrees)
- **SHIP:ORBIT:LONGAN** - Longitude of ascending node (degrees)
- **SHIP:ORBIT:ARGUMENTOFPERIAPSIS** - Argument of periapsis (degrees)
- **SHIP:ORBIT:PERIOD** - Orbital period (seconds)
- **SHIP:ORBIT:ETA:APOAPSIS** - Time to apoapsis (seconds)
- **SHIP:ORBIT:ETA:PERIAPSIS** - Time to periapsis (seconds)

## Body Information

### BODY Object
- **BODY:NAME** - Body name (string)
- **BODY:RADIUS** - Equatorial radius (meters)
- **BODY:MU** - Gravitational parameter (m³/s²)
- **BODY:ROTATIONPERIOD** - Rotation period (seconds)
- **BODY:ATM:HEIGHT** - Atmosphere height (meters)
- **BODY:ATM:SCALE** - Atmosphere scale height (meters)

## Flight Control

### SHIP:CONTROL Object
- **SHIP:CONTROL:MAINTHROTTLE** - Main throttle command (0-1)
- **SHIP:CONTROL:PILOTMAINTHROTTLE** - Pilot throttle input (0-1)
- **SHIP:CONTROL:PILOTPITCH** - Pilot pitch input (-1 to 1)
- **SHIP:CONTROL:FACINGVECTOR** - Target facing vector
- **SHIP:FACING** - Current attitude (quaternion/vector representation)
- **SHIP:FACING:FOREVECTOR** - Forward vector of ship

### Steering and Attitude Control
- **LOCK STEERING TO HEADING(h, p, r)** - Lock attitude to heading/pitch/roll
- **LOCK THROTTLE TO value** - Lock throttle (0-1)
- **UNLOCK STEERING** - Release steering control
- **UNLOCK THROTTLE** - Release throttle control

## Input and Triggers

### Action Groups
- **AG0 through AG10** - Custom action groups
- **ON AG{n} { ... }** - Trigger block on action group activation

## Time and Warp

### TIME Object
- **TIME:SECONDS** - Universal time (seconds since epoch)
- **MISSIONTIME** - Mission elapsed time (seconds)
- **YEAR(time)** - Year from time value
- **DAYOFYEAR(time)** - Day of year from time value
- **HOUR(time)** - Hour from time value
- **MINUTE(time)** - Minute from time value
- **SECOND(time)** - Second from time value

### Time Warp
- **KUNIVERSE:TIMEWARP:CANCELWARP()** - Cancel active time warp
- **KUNIVERSE:TIMEWARP:WARPTO(ut)** - Warp to universal time

## File Operations

### FILE Object
- **OPEN(filename)** - Open file for writing (creates if not exists)
- **file:WRITELN(line)** - Write line to file
- **file:CLOSE()** - Close file

## Stage Information

### STAGE Object
- **STAGE:NUMBER** - Current stage number

## Part Information

### Part Objects
- **part:NAME** - Part name (string)
- **part:IGNITION** - Engine ignition state (boolean)
- **part:FLAMEOUT** - Engine flameout state (boolean)
- **part:THRUST** - Current engine thrust (kN)
- **part:MAXTHRUST** - Maximum engine thrust (kN)
- **part:ISP** - Specific impulse (seconds)
- **part:GETMODULE(module_name)** - Get module by name
- **part:HASMODULE(module_name)** - Check if module exists

## Vector Operations

### Vector Type
- **V(x, y, z)** - Create vector
- **vector:X, vector:Y, vector:Z** - Access components
- **vector:MAG** - Vector magnitude

## Mathematical Functions

### Built-in Functions
- **SQRT(x)** - Square root
- **SIN(x)** - Sine (radians)
- **COS(x)** - Cosine (radians)
- **ARCCOS(x)** - Arc cosine (returns radians)
- **ABS(x)** - Absolute value
- **MAX(a, b)** - Maximum value
- **MIN(a, b)** - Minimum value
- **ROUND(x, decimals)** - Round to decimal places
- **PADLEFT(string, length, char)** - Pad string left

## Known Limitations

1. **Accelerometer and Gravioli Detector**: These must be present as parts in the vessel. Access via part iteration only; no direct SHIP:SENSORS interface in kOS 1.4.0.

2. **Gimbal Control**: This autopilot does not control individual engine gimbals. All active engines thrust together.

3. **Terrain Collision Detection**: kOS 1.4.0 does not provide terrain altitude ahead. The autopilot relies on atmospheric density feedback and altitude telemetry.

4. **Precise Orbital Maneuver Timing**: Delta-V calculations are approximate. Fine-tuning of burns requires post-burn verification.

5. **Part Module Access**: Custom part modules require HASMODULE() check before GETMODULE().

## Verified Working Patterns (Phase 1)

- ✓ SHIP:GEOPOSITION for launch site detection
- ✓ SHIP:CONTROL:FACING for attitude control with HEADING() function
- ✓ TIME:SECONDS for timestamping telemetry
- ✓ STAGE and SHIP:ENGINES for staging detection
- ✓ FILE operations for CSV logging
- ✓ Vector math for attitude calculations
- ✓ Orbital elements (INCLINATION, LONGAN, ARGUMENTOFPERIAPSIS, PERIOD)
- ✓ Time warp cancel via KUNIVERSE:TIMEWARP:CANCELWARP()
- ✓ Action groups via ON AG{n} syntax

## Unverified / To Be Tested

- Accelerometer part access patterns (assumed HASMODULE pattern)
- Gravioli Detector part access patterns (assumed part iteration)
- Detailed gimbal and thrust vector control
- Real-time aerodynamic properties (SHIP:Q accuracy in thin atmosphere)

## Performance Notes

- Main loop frequency: 10 Hz (0.1s per cycle)
- Telemetry sampling: 10 Hz (timestamped)
- CSV buffering: 100 samples before flush
- Steering updates: Every cycle (0.1s response)
- Staging decisions: Every cycle with confirmation cycles for flameout
