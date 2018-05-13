% compare fmps with ceilo data at different humidity and percipitation

%% import data
clear;

root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';

% load fmps data
fmps = readtable('fmps_backscatter.txt','Delimiter',',-: ');
fmps.Properties.VariableNames = {'yyyy' 'MM' 'dd' 'hh' 'mm' 'ss' 'backscatter'}; % backscatter in  ((nm^2)*#/cm^3)
fmps.time = datenum(fmps.yyyy,fmps.MM,fmps.dd,fmps.hh,fmps.mm,fmps.ss);

% define timespan (only if fmps data is available
list_dates = fmps.time(1):fmps.time(end);
%list_dates = fmps.time(1):fmps.time(round(end/4)); % for testing, activate upper line if done

% load roveredo meteo data
roveredo = load_ROVACRO(list_dates);

% load ceilo data
ceilo = read_ceilo_from_url(list_dates,root_url);

[cloudPresence, cloudHeight] = getclouds(ceilo);
percipitation = getpercipitation(ceilo);

% load grono meteo data
grono = grono_to_str;


%% normalize to hourly grid in data structure

fmps_time_rounded = datenum_round_off(fmps.time,'hours');
roveredo_time_rounded = datenum_round_off(roveredo.time,'hours');
ceilo_time_rounded = datenum_round_off(ceilo.time,'hours');
data.time = unique(ceilo_time_rounded);

for i = 1:length(data.time)
    data.RCS(:,i) = mean(ceilo.RCS(:,data.time(i) == ceilo_time_rounded),2);
    data.percipitation(i) = mean(double(percipitation(:,data.time(i) == ceilo_time_rounded)));
    data.humidity(i) = mean(roveredo.Humid(data.time(i) == roveredo_time_rounded));
    data.fmps(i) = mean(fmps.backscatter(data.time(i) == fmps_time_rounded));
end

data.RCS_low = mean(data.RCS(1:5,:),1);

data.percipitationMask = data.percipitation>=0.5;

for i = 1:10
    data.humidityMask(i,:) = data.humidity>(i-1)*10 & data.humidity<=(i)*10;
end
%% scatterplots
figure('units','normalized','outerposition',[0 0 1 1])
model = cell(20,1);

for i = 1:20
    subplot(4,5,i);
    if i <= 10
        mask = data.humidityMask(mod(i,10)+1,:) & ~data.percipitationMask;
    else
        mask = data.humidityMask(mod(i,10)+1,:) & data.percipitationMask;
    end
    
    scatter(data.RCS_low(mask),data.fmps(mask),'.');
    ytickformat('%.1f');
    try
    model = fitlm(data.RCS_low(mask),data.fmps(mask));
    plot(model);
    titlestr = {[num2str((mod(i-1,10))*10) '-' num2str((mod(i-1,10)+1)*10) '% RH, R^2: ' num2str(round(model.Rsquared.Ordinary,2)) ],...
        ['p-val: ' num2str(model.Coefficients.pValue(2,:))]};
    catch
    titlestr = [num2str((mod(i-1,10))*10) '-' num2str((mod(i-1,10)+1)*10) '% RH'];
    end
    title(titlestr);
end

% labeling
ax1 = axes('Position',[0 0 1 1],'Visible','off');
axes(ax1) % sets ax1 to current axes

% title
text(.5,.98,'Ceilo RCS vs. FMPS backscatter','HorizontalAlignment','center','FontSize',30);

% axis labels
h = text(.05,.5,'FMPS backscatter [(nm^2)#/cm^3]','HorizontalAlignment','center','FontSize',20);
set(h,'Rotation',90);
text(.5,.05,'Ceilo RCS','HorizontalAlignment','center','FontSize',20);

% percipitation specifiers
h = text(.1,.75,'no percipitation','HorizontalAlignment','center','FontSize',20);
set(h,'Rotation',90);
h = text(.1,.3,'percipitation','HorizontalAlignment','center','FontSize',20);
set(h,'Rotation',90);