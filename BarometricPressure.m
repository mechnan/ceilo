function p = BarometricPressure(z, T, p0, start)
% p = BarometricPressure(z, T, p0, z0)
% calculates baometric pressure from the the temperature profile
%
% inputs
%   z:      altitude
%   T:      air temperature
%   p0:     integration start pressure
%   start:  integration start index for fields z and T
%
% outputs
%   p:  integration result with indices < start set to NaN
%

  if isempty(p0) || isnan(p0), p0 = 1013; end
  if isempty(start) || isnan(start), start = 1; end
  start = max([start, find(isfinite(z),1,'first'), find(isfinite(T),1,'first')]);
  if isempty(start), error('empty start index'); end
  R = 8.315;
  M = 28.97e-3;
  g = 9.81;
  Tabs = T + 273.15;
  dz = z(start+1:end) - z(start:end-1);
  invRT = ( 0.5 / R) * (1./Tabs(start+1:end) + 1./Tabs(start:end-1));
  p = z;
  p(1:start-1) = NaN;
  p(start:end) = p0 * [1; exp(-cumsum(M * g * invRT .* dz))];
end
