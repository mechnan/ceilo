
clear

list_dates = datenum(2018,3,12);
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';


ceilo = read_ceilo_from_url(list_dates,root_url);
aerosol_top = get_TCAL(list_dates);
%% height vs time plot
figure;
pcolor(ceilo.time,ceilo.range,log10(0.75*abs(ceilo.RCS)));
shading flat;
hc = colorbar;
colormap(jet);
caxis([2.4 5.5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 3000]);
hold on
plot(ceilo.time,aerosol_top,'k', 'LineWidth',2)
datetick;
hold off
%%
clouds = getclouds(ceilo);

area(ceilo.time,clouds);
datetick;


%% height averaging
low_profile_value = nanmean(ceilo.RCS(1:5,:),1);

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

