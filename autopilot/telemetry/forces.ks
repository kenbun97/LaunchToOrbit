FUNCTION GetAccelerometerReading {
    FOR part IN SHIP:PARTS {
        IF part:NAME:CONTAINS("accelerometer") OR part:NAME:CONTAINS("linear") {
            IF part:HASMODULE("ModuleKerbalism_Radiation") {
                RETURN part:GETMODULE("ModuleKerbalism_Radiation"):GETFIELD("Radiation").
            }
        }
    }
    RETURN 0.
}

FUNCTION GetGravioliDetectorReading {
    FOR part IN SHIP:PARTS {
        IF part:NAME:CONTAINS("gravioli") OR part:NAME:CONTAINS("gravity") {
            IF part:HASMODULE("ModuleGravityGradient") {
                RETURN part:GETMODULE("ModuleGravityGradient"):GETFIELD("Gradient").
            }
        }
    }
    RETURN 0.
}

FUNCTION GetNetAcceleration {
    LOCAL g IS SHIP:BODY:MU / ((SHIP:ALTITUDE + SHIP:BODY:RADIUS) ^ 2).
    LOCAL net_accel IS (SHIP:THRUST / SHIP:MASS) - g.
    RETURN net_accel.
}

FUNCTION CalculateDragForce {
    RETURN 0.5 * SHIP:Q * (SHIP:AIRSPEED ^ 2) * SHIP:BODY:ATM:SCALE.
}
