function cbfcn_checkbox_mxd(hObj,eventdata)

mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');

hObj = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_mxd');

%delete already existing line
handles.line_mxd = findobj(handles.axes_surface,'Type','line','Tag','line_mxd');
if(ishandle(handles.line_mxd))
    delete(handles.line_mxd);
end;  

if(get(hObj,'Value'))
    %get app data
    chm15k.mxd = getappdata(mainObj,'chm15k_mxd_original');
    chm15k.cho = getappdata(mainObj,'chm15k_cho_original');
    chm15k.time = getappdata(mainObj,'chm15k_time_original');
    chm15k.zenith = getappdata(mainObj,'chm15k_zenith');
    chm15k.altitude = getappdata(mainObj,'chm15k_altitude');
    %draw line
    y = chm15k.mxd-chm15k.cho;
    y(y<0) = NaN;
    y = y*sind(90-100*chm15k.zenith)+chm15k.altitude;
    x = chm15k.time;
    axes(handles.axes_surface);
    handles.line_mxd = line(x,y,'Color','black','LineStyle','none',...
        'Marker','.','Parent',handles.axes_surface,'Tag','line_mxd','ButtonDownFcn',@bdfcn_surface_pcolor);
end

end