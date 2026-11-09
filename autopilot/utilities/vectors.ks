FUNCTION VectorMagnitude {
    PARAMETER _v.
    RETURN SQRT(_v:X ^ 2 + _v:Y ^ 2 + _v:Z ^ 2).
}

FUNCTION VectorNormalize {
    PARAMETER _v.
    LOCAL mag IS VectorMagnitude(_v).
    IF mag = 0 {
        RETURN V(0, 0, 0).
    }
    RETURN V(_v:X / mag, _v:Y / mag, _v:Z / mag).
}

FUNCTION VectorAngleBetween {
    PARAMETER v1, v2.
    LOCAL dot IS VectorDotProduct(v1, v2).
    LOCAL mag1 IS VectorMagnitude(v1).
    LOCAL mag2 IS VectorMagnitude(v2).
    
    IF mag1 = 0 OR mag2 = 0 {
        RETURN 0.
    }
    
    LOCAL cos_angle IS dot / (mag1 * mag2).
    RETURN ARCCOS(MAX(-1, MIN(1, cos_angle))).
}

FUNCTION RotateVector {
    PARAMETER _v, axis, angle_rad.
    
    LOCAL cos_a IS COS(angle_rad).
    LOCAL sin_a IS SIN(angle_rad).
    LOCAL k IS VectorNormalize(axis).
    
    LOCAL part1 IS V(_v:X * cos_a, _v:Y * cos_a, _v:Z * cos_a).
    LOCAL part2 IS V(
        k:X * VectorDotProduct(k, _v) * (1 - cos_a),
        k:Y * VectorDotProduct(k, _v) * (1 - cos_a),
        k:Z * VectorDotProduct(k, _v) * (1 - cos_a)
    ).
    LOCAL part3 IS VectorCrossProduct(k, _v).
    
    RETURN V(
        part1:X + part2:X + part3:X * sin_a,
        part1:Y + part2:Y + part3:Y * sin_a,
        part1:Z + part2:Z + part3:Z * sin_a
    ).
}
