function cbfcn_edit_T01(hObj,eventdata)

mainObj = gcbf;

handles.edit_T0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T0');
handles.edit_T1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_T1');

chm15k.time = getappdata(mainObj,'chm15k_time');
datedn = floor(chm15k.time(1));

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
handles.axes_station_measurements = findobj(mainObj,'Type','axes','Tag','axes_station_measurements');

try
    xlims = [datedn+datenum(['0000-01-00 ' get(handles.edit_T0,'String')],'yyyy-mm-dd HH:MM:SS') datedn+datenum(['0000-01-00 ' get(handles.edit_T1,'String')],'yyyy-mm-dd HH:MM:SS')];
    tol = 0.5/24/3600;
    if(xlims(2)-xlims(1) <= 1/24+tol)
        xticks = datedn:10/24/60:datedn+1;
    elseif(xlims(2)-xlims(1) <= 4/24+tol)
        xticks = datedn:0.25/24:datedn+1;
    elseif(xlims(2)-xlims(1) <= 8/24+tol)
        xticks = datedn:0.5/24:datedn+1;
    else
        xticks = datedn:1/24:datedn+1;
    end

    set(handles.axes_surface,'XLim',xlims,'XTick',xticks);
    datetick(handles.axes_surface,'x','HH:MM','keepticks','keeplimits');
    set(handles.axes_surface_grad,'XLim',xlims,'XTick',xticks);
    datetick(handles.axes_surface_grad,'x','HH:MM','keepticks','keeplimits');
    set(handles.axes_station_measurements,'XLim',xlims,'XTick',xticks);
    datetick(handles.axes_station_measurements,'x','HH:MM','keepticks','keeplimits');
catch err
    return
end

end