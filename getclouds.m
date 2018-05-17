%% getclouds
% extracts information about cloud cover and returns logical clouds vector
% as well as a vector with the base height

function [cloudPresence, cloudHeight] = getclouds(ceilo)

cloudPresence = false(1,size(ceilo.RCS,2));

mask_clouds = logical(ceilo.cbh(1,:) ~= -99999); % mask showing presence of clouds

clouds_time = ceilo.cbhtime(mask_clouds); % mask with times that have clouds

clouds_time = datenum_round_off(clouds_time,'minutes');

rcs_time = datenum_round_off(ceilo.time,'minutes');

n_clouds = zeros(1,length(rcs_time)); % vector with clouds measured per minute

clouds_cbh = ceilo.cbh(1,mask_clouds);

for i = 1:length(rcs_time)
    n_clouds(i) = sum(rcs_time(i) == clouds_time);
    cloudHeight(i) = mean(clouds_cbh(rcs_time(i) == clouds_time));
end

threshold = 1; % threshold for minimal number of clouds per minute

cloudPresence = n_clouds > threshold; % cloud vector

