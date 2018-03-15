% converts u- and v-component to wind speed and direction
% example 1: u=-1, v=-1 -> dd=45,  ff=sqrt(2)
% example 2: u=1,  v=1  -> dd=225, ff=sqrt(2)
% 
% [ff,dd] = uv2ddff(u,v)
% 
% haa: 2013-08-07
function [dd,ff] = uv2ddff(u,v)
% convert to polar coordinates and change direction by 180 degrees, because
% the dd says where the wind comes from!
[dd,ff]=cart2pol(-u,-v);
% convert to degrees
dd = dd/2/pi*360;
% eliminate negative directions
dd(dd<0)=360+dd(dd<0);
% change to meteorological orientation (dd=0 -> north)
dd = mod(90 - dd, 360);

% simpler:
% ff = sqrt(u.^2+v.^2);
% dd = mod(90-atan2(-v,-u)*180/pi,360);

% or:
% [dd,ff]=cart2pol(-u,-v);
% dd = mod(90-dd*pi/180,360);


