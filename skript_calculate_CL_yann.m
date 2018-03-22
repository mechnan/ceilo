%% Calculate a nighttime averaged Pr2 profile

% choose time interval, should be a cloud-free clear night
% (fitting to ceilometer's Pr2 works best during
% nighttime because no contamination from solar photons), and with a
% low aeorol loading in the BL (else need to change the aerosol optical
% depth)
time_inverval = [datenum(2018,3,7,22,30,00),datenum(2018,3,8,6,00,00)];

% load ceilometer data
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';
list_dates = unique(floor(time_inverval));
ceilo = read_ceilo_from_url(list_dates,root_url);

% restrict averaging time to time interval
indt = ceilo.time >= time_inverval(1) & ceilo.time <= time_inverval(2);
% calculate averaged nighttime ceilometer Pr2 profile
night_averaged_profile = nanmean(ceilo.RCS(:,indt),2);

%% Calculate Pr2 molecular signal from std atmosphere
% including correction for water vapor absorption and aerosol extinction.

% add path of needed functions
addpath('./atmosphere/Complete 1976 Standard Atmosphere/');% for atmo
addpath('./atmosphere/');% for get_rayleigh_v3

% calculate standard atmosphere p and T in first 10km, steps of 0.01 km
[Z_stdatm,~,~,T_stdatm, P_stdatm] = atmo(10,0.01);
Z_stdatm = Z_stdatm*1000;% convert altitude from km to m

% calculate molecular extinction from std atmosphere
alpha_mol_stdatm = get_rayleigh_v3(Z_stdatm,P_stdatm,T_stdatm,905,905);
% interpolate molecular extinction to ceilometer altitude bins (use log because
% of linear relationship of extinction with number density (which decreases exponentially))
alpha_mol = exp(interp1(Z_stdatm,log(alpha_mol_stdatm),ceilo.range*sind(90-ceilo.zenith)+ceilo.alt));

% calculate molecular backscatter from extinction, using molecular lidar ratio
Sm = 3/(8*pi);
beta_mol = Sm * alpha_mol;

% estimate water vapour optical depth in BL (increase if seems very moist
% conditions, decrease if seems very dry conditions)
OD_water = 0.061; % midlatitude winter, average in lowest 1km, 908nm-918nm (Wiegner and Gasteiger, AMT, 2015)

% estimate aerosol optical depth in BL (increase if seems more than
% negligible aerosol loading)
OD_aerosols = 0.001;

% calculate expected Pr2 signal above BL, in cloud free region
Pr2mol = beta_mol.*exp(-2*cumtrapz(ceilo.range,alpha_mol)).*exp(-2*OD_water).*exp(-2*OD_aerosols);

%% Compare ceilometer Pr2 to molecular Pr2.

% If ceilometer is scaled properly, both should fit well in the Free
% Troposphere below 3km (indeed, above 3km the signal is distorted and is not a true Pr2 signal
% anymore)

% EXERCISE: change CL value until it fits!
CL = 1e-11;% inverse lidar constant, i.e. scaling factor

figure;
plot(Pr2mol,ceilo.range,'--k','DisplayName','molecular profile');
hold on;
plot(CL*night_averaged_profile,ceilo.range,'-r','DisplayName','ceilometer profile, with freely chosen scaling factor');
xlabel('attenuated backscatter coefficient [m-1sr-1]');
ylabel('range [m]');
xlim([0 2]*1e-6);ylim([0 3000]);
legend('Location','NorthEast');

% Automatic fit of CL

% range where you think you are for sure in the Free Troposphere (below 3000m)
% and you have no aerosol or cloud layers
indr = ceilo.range>=200 & ceilo.range <= 3000;
% calculate average scaling factor
CLfit = nanmean(Pr2mol(indr)./night_averaged_profile(indr));
% plot
plot(CLfit*night_averaged_profile,ceilo.range,'-g','DisplayName','ceilometer profile, with calculated average scaling factor');

disp(['Fitted inverse lidar constant: ' num2str(CLfit)]);