%Plot TCAL over RCS
function answ = plot_TCA(list_dates,url,TCAL)
%list_dates=datenum(2018,02,20):datenum(2018,02,22)
%url='http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/'
%TCAL=1, if should be plotted

%read ceilo
ceilo=read_ceilo_from_url(list_dates,url);

% Plot RCS
figure;
pcolor(ceilo.time,ceilo.range,log10(abs(ceilo.RCS)));
shading flat;
hc = colorbar;
colormap(jet);
 caxis([3 5]);
%set(gca, 'YScale', 'log')
datetick;
ylim([0 4000]);
answ='a';
hold on

%plot TCAL
if TCAL==1
    TCAL=get_TCAL(list_dates);
    plot(ceilo.time,TCAL,'Linewidth',4)
    hold on
end


end