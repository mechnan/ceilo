%% getpercipitation
% extracts information about percipitation and returns logical percipitation vector

% Niederschlagsalgorithmus Idee, 
% Niederschlag an Zeit ti falls:
% i)   keine Wolke in untersten 50m (sonst hat man vermutlich mit einer Art Nebel zu tun)
% ii)  Mindestens eine Wolke höher als 50m in dem interval [ti-10minuten,ti] 
%      (Niederschlag muss aus einer Wolke fallen),
% iii) mean(RCS)>threshold_niederschlag zwischen 
%      Boden und tiefste Wolke mit höhe > 50 m in letzen 10 minuten
% iv)  Qualitätscheck: Qualität==2 falls Niederschlag gemessen in Grono 
%      in den 2 Stunden rundum, Qualität==1 sonst.


function percipitaion = getpercipitation(ceilo)


end