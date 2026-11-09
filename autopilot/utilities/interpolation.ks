FUNCTION LinearInterpolation {
    PARAMETER value1, value2, t.
    
    RETURN value1 + (value2 - value1) * t.
}

FUNCTION SmoothstepInterpolation {
    PARAMETER value1, value2, t.
    
    LOCAL s IS 10 * (t ^ 3) - 15 * (t ^ 4) + 6 * (t ^ 5).
    RETURN value1 + (value2 - value1) * s.
}

FUNCTION ClampValue {
    PARAMETER value, min_val, max_val.
    
    IF value < min_val {
        RETURN min_val.
    }
    IF value > max_val {
        RETURN max_val.
    }
    RETURN value.
}

FUNCTION NormalizeValue {
    PARAMETER value, min_val, max_val.
    
    IF min_val = max_val {
        RETURN 0.
    }
    
    RETURN (value - min_val) / (max_val - min_val).
}

FUNCTION Lerp {
    PARAMETER start, end, t.
    RETURN start + (end - start) * ClampValue(t, 0, 1).
}
