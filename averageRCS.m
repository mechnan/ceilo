%calculates average RSC in lowest 30m at clear conditions

%ceilo=readCeilo(list_dates)
%makePlot=1 if averageRCS should be plotted
%plotRCS=1 if RCS colormap should be plotted
function average_RCS = averageRCS(ceilo,makePlot,plotRCS)
average_RCS = nanmean(ceilo.RCS(1:3,:),1);

%clear condition
clouds=getclouds(ceilo);

%plotRCS
if plotRCS==1
    pcolor(ceilo.time,ceilo.range,log10(abs(ceilo.RCS)));
    shading flat;
    %hc = colorbar;
    colormap(jet);
    caxis([3 5]);
    datetick;
    ylim([0 100]);
        
end

for i=1:length(ceilo.RCS)
    if clouds(i)==1
        average_RCS(i)=NaN;
    end
end
average_RCS=movmean(average_RCS,200,'omitnan');

if makePlot==1
    if plotRCS==1
    yyaxis right
    end
    plot(ceilo.time,average_RCS)
    datetick;
end
end
