function plot_stabilitaet(Messdaten)
% Code für die Berechnung und das Plotten vom Stabilitätsindex und 1h-Temperaturwechsel wie in
% Pal et al. (2013), J. Geophys. Res. Atmos., 118(16), 9277–9295, doi:10.1002/jgrd.50710

%% Berechne
time = Messdaten(:,1);
MoninObukhovL = 4.5./Messdaten(:,13);
SensHeatFlux = Messdaten(:,2);
T = Messdaten(:,9);

% berechne Stabilitätsindex basierend auf Monin-Obukhov Länge
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
        
        % indices 6 and 1 can be very close to each other for small
        % abs(Monin-Obukhov length) and are very sensitive to sign of
        % sensible heat flux
        % -> ensure that sensible heat flux is large enough (>= 10 W/m^2)
        % to treat as very unstable, else treat as stable
        if SensHeatFlux(i)<10
            stability_index(i) = 1;
        end
        
    end
end

% berechne stündigen-Stabilitätsindex und stündigen-Temperaturwechsel
datetime_hourly = floor(time(1))+0.5/24:1/24:ceil(time(end))-0.5/24;
stability_index_hourly = NaN(length(datetime_hourly),1);
diffT_hourly = NaN(length(datetime_hourly),1);
for i=1:length(stability_index_hourly)
    mask = time>=datetime_hourly(i)-0.5/24 & time<datetime_hourly(i)+0.5/24;
    counts = hist(stability_index(mask),[1 2 3 4 5 6]);
    if any(~isnan(counts)) && any(counts)
        [~,imax] = max(counts);
        stability_index_hourly(i) = imax;
    else
        stability_index_hourly(i) = NaN;
    end
    
    mask_after = time>=datetime_hourly(i) & time<datetime_hourly(i)+1/24;
    mask_before = time>=datetime_hourly(i)-1/24 & time<datetime_hourly(i);
    diffT_hourly(i) = (mean(T(mask_after),'omitnan')-mean(T(mask_before),'omitnan'));
end

%% Plot

% wähle figure oder subplot
figure;
% subplot(7,1,7);

% "0"-Linie
plot(datetime([floor(time(1)),ceil(time(end))],'convertfrom','datenum'),3.5*ones(1,2),'--k');

hold on;
%15-min Stabilität
% stem(datetime(time,'convertfrom','datenum'),stability_index,'Color',[0.8 0.2 0.2],'marker','none');
%1h-Stabilität und 1h-Temperaturwechsel
[ax,p1,p2] = plotyy(datetime(datetime_hourly,'convertfrom','datenum'),stability_index_hourly,datetime(datetime_hourly,'convertfrom','datenum'),3.5+3*diffT_hourly/max(abs(diffT_hourly),[],'omitnan'));


set(ax(1),'ytick',0:1:7,'yticklabel',{'','stable','near neutral','neutral','near neutral unstable','unstable','very unstable',''},'ylim',[0 7]);
set(ax(2),'ytick',0:1:7,'yticklabel',num2str(((0:1:7)'-3.5)*max(abs(diffT_hourly),[],'omitnan')/3,'%2.1f'),'ylim',[0 7]);
set(p1,'marker','.');
set(p2,'marker','.');
ylabel(ax(1),'Stabilität');
ylabel(ax(2),'\DeltaT(1h) [K]');


% plotte Sonnenaufgang und Sonnenuntergäng für jeden Tag
hold on;
addpath('./atmosphere/');
unique_days = unique(floor(time));
for i=1:length(unique_days)
    
    % Berechne Sonnenaufgang & Sonnenuntergang
    rs = suncycle(46.23049,9.11436,unique_days(i));% (lat,lon) hier von Messwagen Roveredo
    sunrise = unique_days(i)+rs(1)/24;
    sunset = unique_days(i)+rs(2)/24;
    
    plot(datetime(sunrise,'convertfrom','datenum'),0,'^','color','k','markerfacecolor','k');
    plot(datetime(sunset,'convertfrom','datenum'),0,'v','color','k','markerfacecolor','k');

end

xlabel('Zeit');
title('Stabilität', 'FontSize',10, 'FontWeight', 'bold');
grid on;

end

