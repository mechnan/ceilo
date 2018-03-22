
clear;

list_dates = datenum(2018,3,12);
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';


ceilo = read_ceilo_from_url(list_dates,root_url);

%% height vs time plot
figure;
pcolor(ceilo.time,ceilo.range,log10(abs(ceilo.RCS)));
shading flat;
hc = colorbar;
colormap(jet);
caxis([3 4.5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 3000]);

%% clouds
[cloudPresence, cloudHeight] = getclouds(ceilo);

figure;
area(ceilo.time,cloudPresence);
datetick;

figure;
plot(ceilo.time,cloudHeight)

%% percipitation

figure;
subplot(3,1,1);
pcolor(ceilo.time,ceilo.range,log10(abs(ceilo.RCS)));
shading flat;
colormap(jet);
caxis([3 4.5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 3000]);
percipitation = getpercipitation(ceilo);

subplot(3,1,2);
area(ceilo.time,percipitation);
datetick;

% grono percipitation data
subplot(3,1,3);
startdate = datenum(2018,3,12);
enddate   = datenum(2018,3,13);
index_start=find(data.time==startdate);
index_end=find(data.time==enddate);
plot(data.N93(index_start:index_end));

%% height averaging
low_profile_value = nanmean(ceilo.RCS(45:55,:),1);

figure;
plot(ceilo.time,low_profile_value);
datetick;
ylabel('Mean backscatter over first 50m');
xlabel('time UT');

%% time averaging
mask_time = mod(ceilo.time,1)>=6/24 & mod(ceilo.time,1)<=15/24 ; 
mean_profile = nanmean(ceilo.RCS(:,mask_time),2);

figure;
plot(mean_profile,ceilo.range);
datetick;
ylabel('Heigth m');
xlabel('Mean backscatter');
xlim([-10000 30000]);
ylim([0 2100]);

