function average_RCS = averageRCS_daily(ceilo)
time = datetime(ceilo.time,'ConvertFrom','datenum');
time = timeofday(time);
[pks,locs] = findpeaks(datenum(time));
locs=[2,locs,length(time)-1];
average_RCS=averageRCS(ceilo,0,0);
legendString={};
for i=1:numel(locs)-1
    plot(time(locs(i)+1:locs(i+1)),average_RCS(locs(i)+1:locs(i+1)))
    hold on
    date=datestr(ceilo.time(locs(i)+1000),'yyyy mm dd');
    legendString=[legendString,date];
end

legend(legendString)
title('Mittlere Rückstreuung in untersten 30m')
end