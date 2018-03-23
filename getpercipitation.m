%% getpercipitation
% extracts information about percipitation and returns percipitation quality vector

% Niederschlagsalgorithmus Idee,
% Niederschlag an Zeit ti falls:
% i)   keine Wolke in untersten 50m (sonst hat man vermutlich mit einer Art Nebel zu tun)
% ii)  Mindestens eine Wolke höher als 50m in dem interval [ti-10minuten,ti]
%      (Niederschlag muss aus einer Wolke fallen),
% iii) mean(RCS)>threshold_niederschlag zwischen
%      Boden und tiefste Wolke mit höhe > 50 m in letzen 10 minuten
% iv)  Qualitätscheck: Qualität==2 falls Niederschlag gemessen in Grono
%      in den 2 Stunden rundum, Qualität==1 sonst.


function percipitation = getpercipitation(ceilo)

thresholdPercipitation = 6*10^4; % empirical threshold for percipitation
thresholdFraction = 0.6; % fraction of profile between ground and cloud that has to show percipitation
fogHeight = 100; % discard cbh's up to this hight as percipitation source

[cloudPresence, cloudHeight] = getclouds(ceilo); % percipitation only in presence and under clouds

n_percipitation = zeros(1,size(ceilo.RCS,2));
n_nopercipitation = zeros(1,size(ceilo.RCS,2));

for i = 1:size(ceilo.RCS,2)
    for j = 1:size(ceilo.RCS,1)
        mask_underCloud(j,i) = logical(ceilo.range(j) < cloudHeight(i));
        if mask_underCloud(j,i) == 1
            if ceilo.RCS(j,i) > thresholdPercipitation
                n_percipitation(i) = n_percipitation(i) + 1;
            else
                n_nopercipitation(i) = n_nopercipitation(i) +1;
            end
        end
    end
    fract_percipitation(i) = n_percipitation(i)/(n_percipitation(i) + n_nopercipitation(i));
    if cloudHeight(i) < fogHeight
        fract_percipitation(i) =0;
    end
end

rcs_percipitation = logical(fract_percipitation > thresholdFraction);

percipitation = rcs_percipitation;
end






