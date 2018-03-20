function [k,b] = getPlanarFitCoeffs(u,v,w)

% GETPLANARFITCOEFFS Determine the planar fit coefficients
% for coordinate rotation (see e.g. Handbook of Micrometeorology, Lee et
% al. 2004).
%
% INPUTS:
% run-averaged wind velocity data in the instrument coordinates.
%
% OUTPUTS:
% k: unit vector parallel to the new z-axis
% b: tilt coefficients b0, b1, b2

% AUTHOR: Patrick Sturm <pasturm@ethz.ch>
%
% COPYRIGHT 2008 Patrick Sturm
% This file is part of Eddycalc.
% Eddycalc is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% For a copy of the GNU General Public License, see
% <http://www.gnu.org/licenses/>.

l   = length(u);
su  = sum(u);
sv  = sum(v);
sw  = sum(w);
suv = u'*v;
suw = u'*w;
svw = v'*w;
su2 = u'*u;
sv2 = v'*v;
H   = [l su sv; su su2 suv; sv suv sv2];
g   = [sw suw svw]';
b   = H\g; % tilt coefficients

% determine unit vector parallel to the new z-axis
k(3) = 1/sqrt(1+b(2)^2+b(3)^2);
k(1) = -b(2)*k(3);
k(2) = -b(3)*k(3);

