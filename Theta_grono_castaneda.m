%% stability index from pot. Temperatur Grono - Castaneda

% load Grono data then Run


%% calculate mean potential temperature at Grono and Castaneda
list_dates = datenum(2018,2,20):datenum(2018,3,09);

time_theta = floor(list_dates(1)):1/24:ceil(list_dates(end));

ground_data = data; % from read_GRONO_from_data
slope_data = get_station_data_TI('castadena',list_dates);

[ground_theta, slope_theta] = deal(NaN(length(time_theta),1));

for i=2:length(time_theta)
   indt = ground_data.time>time_theta(i-1) & ground_data.time<=time_theta(i);
   indtslope = slope_data.time>time_theta(i-1) & slope_data.time<=time_theta(i);
   
   ground_T = nanmean(ground_data.T91(indt)+273.15);
   ground_p = nanmean(ground_data.P90(indt));
   ground_theta(i) = ground_T.*(1000./ground_p).^(287/1005);

   slope_T = nanmean(slope_data.T(indtslope)+273.15);
   p770m = BarometricPressure([324 770],[ground_T slope_T], ground_p, 1);
   slope_p = p770m(2);
   slope_theta(i) = slope_T.*(1000./slope_p).^(287/1005);
end

%% sonic data for stability index Sonic Roveredo

% path='/Users/RemoSigg/polybox/ETH-ERDW/ERDW - 6.Semester/Praktikum Atmosphäre/Ceilometergruppe/CeilometerFS2018/data/Sonic';
% 
% time_period = list_dates(1):15/60/24:list_dates(end);
% 
% sonic = read_sonic_run_from_files(time_period, path);
% 
% time = sonic(:,1);
% MoninObukhovL = 4.5./sonic(:,13);
% SensHeatFlux = sonic(:,2);
% T = sonic(:,9);

%% calculate stability index
stability_index = NaN(length(MoninObukhovL),1);
for i=1:length(MoninObukhovL)
    if MoninObukhovL(i)>=0.01 && MoninObukhovL(i)<200
        stability_index(i) = 1;% stable
    elseif MoninObukhovL(i)>=200 && MoninObukhovL(i)<500
        stability_index(i) = 2;% near neutral
    elseif MoninObukhovL(i)>=500 || MoninObukhovL(i)<=-500
        stability_index(i) = 3;% neutral
    elseif MoninObukhovL(i)>-500 && MoninObukhovL(i)<=-200
        stability_index(i) = 4;% near neutral unstable
    elseif MoninObukhovL(i)>-200 && MoninObukhovL(i)<=-100
        stability_index(i) = 5;% unstable
    elseif MoninObukhovL(i)>-100 && MoninObukhovL(i)<=-0.01
        stability_index(i) = 6;% very unstable
        
       if SensHeatFlux(i)<10
            stability_index(i) = 1;
        end
    end
    
    if stability_index(i) == 1 || stability_index(i) == 2
        stability_index(i) = 1; % stable
    elseif stability_index(i) == 3 || stability_index(i) == 4
        stability_index(i) = 0; % neutral
    elseif stability_index(i) == 5 || stability_index(i) == 6 
        stability_index(i) = -1; % unstable
        
    end
end


% calculate hourly stability index
datetime_hourly = floor(time(1))+0.5/24:1/24:ceil(time(end))-0.5/24;
stability_index_hourly = NaN(length(datetime_hourly),1);
for i=1:length(stability_index_hourly)
    mask = time>=datetime_hourly(i)-0.5/24 & time<datetime_hourly(i)+0.5/24;
    counts = hist(stability_index(mask),[-1 0 1]);
    if any(~isnan(counts)) && any(counts)
        [~,imax] = max(counts);
        stability_index_hourly(i) = imax;
    else
        stability_index_hourly(i) = NaN;
    end
    
    mask_after = time>=datetime_hourly(i) & time<datetime_hourly(i)+1/24;
    mask_before = time>=datetime_hourly(i)-1/24 & time<datetime_hourly(i);
end


%% plot stability index Grono - Castaneda

stability_index2 = NaN(length(slope_theta),1);
for i=1:length(slope_theta)
    if slope_theta(i)-ground_theta(i)>=1 
        stability_index2(i) = 3;% stable
    elseif slope_theta(i)-ground_theta(i)<=-0.5
        stability_index2(i) = 1;% unstable
    else
        stability_index2(i) = 2;% neutral        
    end
end


figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot(datetime(time_theta,'convertfrom','datenum'),stability_index2,'o-');
hold on;
plot(datetime(datetime_hourly,'convertfrom','datenum'), stability_index_hourly,'+-r')
ax = gca;
set(ax(1),'ytick',0:1:4,'yticklabel',{'','unstable','neutral','stable',''},'ylim',[0.5 3.5]);
xticks(datetime(list_dates,'convertfrom','datenum'));
xlim([datetime(list_dates(1),'convertfrom','datenum') datetime(list_dates(end),'convertfrom','datenum')])
title('Stabilitätsindex')
ylabel('Stabilität');
xlabel('Zeit');
legend('pot. Temperatur Grono - Castaneda','sonic data');
grid on;


%% Plot Theta difference

hold on;

subplot(2,1,2)
list_plots = [];
list_legends = {};

list_plots(end+1) = plot(datetime(time_theta,'convertfrom','datenum'),(slope_theta-ground_theta),'*-g');
list_legends{end+1} = '\Delta\Theta (K)';
xticks(datetime(list_dates,'convertfrom','datenum'));
xlim([datetime(list_dates(1),'convertfrom','datenum') datetime(list_dates(end),'convertfrom','datenum')])
xlabel('Zeit');
title('\theta Differenz')
legend(list_plots,list_legends);
grid on;box on;

