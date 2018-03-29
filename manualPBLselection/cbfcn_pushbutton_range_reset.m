function cbfcn_pushbutton_range_reset(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

handles.edit_R0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R0');
handles.edit_R1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_R1');

set(handles.edit_R0,'String','0');
set(handles.edit_R1,'String','3000');

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

try
    ylims = [str2double(get(handles.edit_R0,'String')) str2double(get(handles.edit_R1,'String'))];
    tol = 1;
    if(ylims(2)-ylims(1) <= 1500+tol)
        yticks = 0:100:16000;
    elseif(ylims(2)-ylims(1) <= 3000+tol)
        yticks = 0:250:16000;
    elseif(ylims(2)-ylims(1) <= 8000+tol)
        yticks = 0:500:16000;
    else
       yticks = 0:1000:16000;
    end

    set(handles.axes_surface,'YLim',ylims,'YTick',yticks);
    set(handles.axes_surface_grad,'YLim',ylims,'YTick',yticks);
catch err
    return
end

end