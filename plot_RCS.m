function ceilo = plot_RCS(start_date,end_date,save_path)
%start_date = '2018,2,17'
%end_date = '2018,2,20'
%save_path = 'C:\Users\sara\Desktop\RCS\'


NumDays = daysact(start_date,end_date)+1;
date = addtodate(datenum(start_date), -1, 'day');
for i= 1:NumDays
    date = addtodate(date,1,'day');
    root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';
    ceilo = read_ceilo_from_url(date,root_url);
    utc = datestr(date,'yyyy,mm,dd');
    
    figure
    pcolor(ceilo.time,ceilo.range,log10(0.75*abs(ceilo.RCS)));shading flat;%ceilo.range= hoehe, rcs=range corrected signal
    hc = colorbar; %legende
    colormap(jet); %farbskala anpassen
    caxis([3 5]); %minimal und maximal wert auf farbskala
    datetick; %datum formatieren
    ylim([0 4000])
    xlim([date addtodate(date,1,'day')])
    title(utc)
    
    
    filename=['RCS-' utc '.jpeg'];
    fname = save_path;
    saveas(gca, fullfile(fname, filename), 'jpeg');
    close(gcf)
end
end
