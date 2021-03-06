%correlate RCS to FMPS

%%read fmps file

%initializing
data.year   = []; % Jahr
data.month  = []; % Monat
data.day    = []; % Tag
data.hour   = []; % Stunde
data.min    = []; % Minute
data.time=[];
data.fmps=[];

%filepath
filepath = pwd;
filename = [filepath '/' 'fmps_backscatter.txt'];
disp(filename);

% read data - first determining headerlines
fid = fopen(filename);
frewind(fid);

c = textscan(fid,'%f %f %f %f %f %f %f','Headerlines',1);
fclose(fid);


data.year   = [data.year;  c{ 1}]; 
data.month  = [data.month; c{ 2}];
data.day    = [data.day;   c{ 3}]; 
data.hour   = [data.hour;  c{ 4}]; 
data.min    = [data.min;   c{ 5}];
data.fmps   = [data.fmps;  c{ 7}];
data.time = datenum(data.year,data.month,data.day,data.hour,data.min,0);



%% read ceilo
startdate = data.time(1);
enddate = data.time(length(data.time));

list_dates=(startdate:enddate);
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';
ceilo = read_ceilo_from_url(list_dates,root_url);

%% calculate average RCS
RCS = nanmean(ceilo.RCS(1:3,:),1);

%% filter clouds and humidity
clouds=getclouds(ceilo);
precipitation=getpercipitation(ceilo);
noclouds=~clouds;
noprecipitation=~precipitation;

RCS_clearCondition =RCS(noclouds & noprecipitation);
time_RCS = ceilo.time(noclouds & noprecipitation);
%% Stundenmittel berechnen
startdate = data.time(1);
enddate = data.time(length(data.time));

hdat=[];
hfmps=[];
hRCS=[];

for dat=startdate:1/24:enddate
    hdat=[hdat; dat+0.5/24];
    
    %fmps
    mask_periode = (data.time>=dat)&(data.time<(dat+1/24));
    mask_finite=isfinite(data.fmps);
    hfmps=[hfmps;mean(data.fmps(mask_periode & mask_finite))];
    
    %RCS
    mask_periode = (time_RCS>=dat)&(time_RCS<(dat+1/24));
    mask_finite=isfinite(RCS_clearCondition);
    hRCS=[hRCS;nanmean(RCS_clearCondition(mask_periode & mask_finite))];
end




%% Figure
figure(1)
plot(hdat,hfmps)
hold on
yyaxis right
plot(hdat,hRCS)
xlabel('time')
datetick('x','dd/mm HHPM','keepticks','keeplimits');
legend('hfmps','RCS')
legend

%% lineare Regression
figure(2)
scatter(hRCS,hfmps)
xlabel('RCS')
ylabel('FMPS')
hold on
mld=fitlm(hRCS,hfmps);
adjR2=mld.Rsquared.Adjusted;
b0=mld.Coefficients(1,1);
b1=mld.Coefficients(2,1);
pValue_b1=mld.Coefficients(2,4);
fitted=mld.Fitted;
plot(hRCS,fitted)
titlestring=strcat('Regression von RCS und FMPS:', '  clear condition');
title(titlestring)

dim=[0.2 0.5 0.3 0.3];
str=strcat(' adjusted R^2=',num2str(adjR2),', pValue=',num2str(table2array(pValue_b1)));
annotation('textbox',dim,'String',str,'FitBoxToText','on');