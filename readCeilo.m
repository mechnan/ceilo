
clear;


list_dates = datenum(2018,3,7);
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';


ceilo = read_ceilo_from_url(list_dates,root_url);
aerosol_top = get_TCAL(list_dates);
%% height vs time plot
figure;
pcolor(ceilo.time,ceilo.range,log10(abs(0.75*(ceilo.RCS))));
shading flat;
hc = colorbar;
colormap(jet);
caxis([2.4 5.5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 3000]);
title('Height vs Time Plot')
hold on
plot(ceilo.time,aerosol_top,'k', 'LineWidth',2)
datetick;
hold off
%% clouds
[cloudPresence, cloudHeight] = getclouds(ceilo);

figure;
area(ceilo.time,cloudPresence);
datetick;
xlabel('Time UTC')
ylabel('Presence of clouds')
title('Presence of Clouds')

figure;
plot(ceilo.time,cloudHeight)
xlabel('Time UTC')
ylabel('Height of clouds [m]')
title('Height of Clouds')
datetick;
%% percipitation

figure;
subplot(3,1,1);
pcolor(ceilo.time,ceilo.range,log10(abs(0.75*(ceilo.RCS))));
shading flat;
colormap(jet);
caxis([2.4 5.5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 3000]);
percipitation = getpercipitation(ceilo);
title('RCS in Height vs. Time')

subplot(3,1,2);
area(ceilo.time,percipitation);
datetick;
title('Precipitation Presence')

% grono percipitation data
data.year   = []; % Jahr
data.month  = []; % Monat
data.day    = []; % Tag
data.hour   = []; % Stunde
data.min    = []; % Minute
data.N93    = []; % 93 Niederschlag; Zehnminutensumme [mm]

% path to Grono data
filepath = pwd;
filename = [filepath '/' 'GRONO_SWISSMETNET_all.dat'];

% read data - first determining headerlines
fid = fopen(filename);
frewind(fid);
c = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ','Headerlines',27);
fclose(fid);
data.year   = [data.year;  c{ 2}]; 
data.month  = [data.month; c{ 3}];
data.day    = [data.day;   c{ 4}]; 
data.hour   = [data.hour;  c{ 5}]; 
data.min    = [data.min;   c{ 6}]; 
data.N93    = [data.N93;   c{12}]; 

% set 'serial date time' for each messurement
data.time = datenum(data.year,data.month,data.day,data.hour,data.min,0);


subplot(3,1,3);
startdate = list_dates;
enddate   = list_dates+1;

% ev. transformation of grono data in utc time
% if startdate < 737143             %solar time
%     data.hour=data.hour+1;
% elseif startdate == 737143        %24.03 change of time at 02:00
%     if data.hour < 2
%         data.hour=data.hour+1;
%     else
%         data.hour=data.hour+2;
%     end    
% else                              %legal time
%     data.hour=data.hour+2;
% end
% 
% data.time = datenum(data.year,data.month,data.day,data.hour,data.min,0);

index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
plot(data.time(index_start:index_end), data.N93(index_start:index_end));
xlabel('Local Time')
ylabel('Precipitation, 10 minutes mean [mm]')
title('Precipitation in Grono Station')
datetick;
%% height averaging
low_profile_value = nanmean(ceilo.RCS(45:55,:),1);

figure;
plot(ceilo.time,low_profile_value);
datetick;
ylabel('Mean backscatter over first 50m');
xlabel('time UT');

%% time averaging
mask_time = mod(ceilo.time,1)>=21/24 & mod(ceilo.time,1)<=23/24 ; 
mean_profile = nanmean(ceilo.RCS(:,mask_time),2);

figure;
plot(mean_profile,ceilo.range);
datetick;
ylabel('Heigth m');
xlabel('Mean backscatter');
xlim([-10000 30000]);
ylim([0 2100]);

