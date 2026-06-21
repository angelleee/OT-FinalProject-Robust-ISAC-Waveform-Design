function diff = angle_diff_deg(a, b)
%ANGLE_DIFF_DEG Wrapped angle difference a-b in degrees in [-180,180).
    diff = mod(a - b + 180, 360) - 180;
end
