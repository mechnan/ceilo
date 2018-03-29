function cbfcn_checkbox_cbh(hObj,eventdata)

mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');

hObj = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_cbh');

%delete already existing line
handles.line_cbh = findobj(handles.axes_surface,'Type','line','Tag','line_cbh');
if(ishandle(handles.line_cbh))
    delete(handles.line_cbh);
end;  

if(get(hObj,'Value'))
    %get app data
    chm15k.cbh = getappdata(mainObj,'chm15k_cbh_original');
    chm15k.cho = getappdata(mainObj,'chm15k_cho_original');
    chm15k.time = getappdata(mainObj,'chm15k_time_original');
    chm15k.zenith = getappdata(mainObj,'chm15k_zenith');
    chm15k.altitude = getappdata(mainObj,'chm15k_altitude');
    %draw line
    y = chm15k.cbh-chm15k.cho;
    y(y<0) = NaN;
    y = y*sind(90-100*chm15k.zenith)+chm15k.altitude;
    x = chm15k.time;
    axes(handles.axes_surface);
    handles.line_cbh = line(x,y,'Color',[0.5 0.5 0.5],'LineStyle','none',...
        'Marker','.','Parent',handles.axes_surface,'Tag','line_cbh','ButtonDownFcn',@bdfcn_surface_pcolor);
end

end