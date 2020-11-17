function  value = cap(in, lowerLimit, upperLimit)
% This function checks input coordinates whether inside the limits.

% =========================================================================
% Input:
% in            -   input coordinates.
% lowerLimit    -   lower limit for coordinates.
% upperLimit    -   upper limit for coordinates.
% =========================================================================
% Output:
% value        -    output after limits are applied to input coordinates.
% =========================================================================

in( in(:) > upperLimit ) = upperLimit;
in( in(:) < lowerLimit ) = lowerLimit;

value = in;

end