function z = BarometricAltitude(p, T, z0, start)
% z = BarometricPressure(p, T, p0, z0)
% calculates barometric altitude from the the temperature profile
%
% inputs
%   p:      air pressure
%   T:      air temperature
%   z0:     integration start altitude
%   start:  integration start index for fields p and T
%
% outputs
%   z:  integration result with indices < start set to NaN
%
  if isempty(z0) || isnan(z0), z0 = 0; end
  if isempty(start) || isnan(start), start = 1; end
  start = max([start, find(isfinite(p),1,'first'), find(isfinite(T),1,'first')]);
  if isempty(start), error('empty start index'); end
  R = 8.315;
  M = 28.97e-3;
  g = 9.81;
  Tabs = PrecNoNan(T) + 273.15;
  p = PrecNoNan(p);
  dp = p(start+1:end) - p(start:end-1);
  Toverp = 0.5 * ( Tabs(start+1:end) ./ p(start+1:end) + ...
    Tabs(start:end-1) ./ p(start:end-1) );
  z = NaN(size(p));
  z(start:end) = [z0; z0-cumsum((R * Toverp .* dp) / (M * g ))]; 
end
