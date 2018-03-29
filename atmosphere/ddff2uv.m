% converts wind speed/direction to u- and v-components
% example 1: u=-1, v=-1 -> dd=45,  ff=sqrt(2)
% example 2: u=1,  v=1  -> dd=225, ff=sqrt(2)
%
% [u,v] = ddff2uv(dd,ff)
% 
% haa, 2013-08-07
function [u,v] = ddff2uv(dd,ff)

[u, v] = pol2cart( (-dd-90)*pi/180, ff );