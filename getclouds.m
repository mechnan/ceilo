%% getclouds
% extracts information about cloud cover and returns logical clouds vector

function clouds = getclouds(ceilo)

mask_clouds = logical(ceilo.cbh(1,:) ~= -99999); % mask showing presence of clouds

clouds_time = ceilo.cbhtime(mask_clouds); % mask with times that have clouds

clouds_time = datenum_round_off(clouds_time,'minutes');

rcs_time = datenum_round_off(ceilo.time,'minutes');

n_clouds = zeros(length(rcs_time),1); % vector with clouds measured per minute

for i = 1:length(rcs_time)
    n_clouds(i) = sum(rcs_time(i) == clouds_time);
end

threshold = 10; % threshold for number of clouds per minute

clouds = n_clouds > threshold; % cloud vector

