function [wind2,theta,phi] = rotateWindVector(wind,method,k)

% ROTATEWINDVECTOR Transform wind to mean streamline coordinate system
% using double rotation, triple rotation or the planar fit method (Wilczak
% et al., 2001, Boundary-Layer Meteorology).
%
% INPUTS:
% wind:   data matrix with the u,v,w wind components
% method: string 'DR', 'TR' or 'PF' to perform double rotation,
%         triple rotation or planar fit.
% k:      unit vector of the z-axis (only used for 'PF')
%
% OUTPUTS:
% wind2:      data matrix with rotated wind components
% theta, phi: rotation angles

% AUTHOR: Patrick Sturm <pasturm@ethz.ch>
%
% COPYRIGHT 2008-2010 Patrick Sturm
% This file is part of Eddycalc.
% Eddycalc is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% For a copy of the GNU General Public License, see
% <http://www.gnu.org/licenses/>.

if strcmp(method,'PF')

	% determine unit vectors i and j parallel to the new x and y axis
	j = cross(k,mean(wind));
	j = j/(sum(j.*j))^0.5;
	i = cross(j,k);

	% wind velocities in new coordinates
	wind2 = wind*[i' j' k'];
	phi = acos(dot(k,[0 0 1]));
	theta = atan2(mean(-wind(:,2)),mean(wind(:,1)));

else

	% mirror y-axes to get right-handed coordinate system (depends on the sonic)
	wind(:,2) = -wind(:,2);

	% first rotation to set mean(v) = 0
	theta = atan2(mean(wind(:,2)),mean(wind(:,1)));
	rot1  = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
	wind1 = wind*rot1;

	% second rotation to set mean(w) = 0
	phi = atan2(mean(wind1(:,3)),mean(wind1(:,1)));
	rot2  = [cos(phi) 0 -sin(phi); 0 1 0; sin(phi) 0 cos(phi)];
	wind2 = wind1*rot2;

	% third rotation to set mean(vw) = 0
	if strcmp(method,'TR')
		psi = 0.5*atan2(2*mean(wind2(:,2).*wind2(:,3)),mean(wind2(:,2).^2)-mean(wind2(:,3).^2));
		rot3  = [1 0 0; 0 cos(psi) -sin(psi); 0 sin(psi) cos(psi)];
		wind2 = wind2*rot3;
	end
end

