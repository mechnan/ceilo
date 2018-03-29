function cbfcn_checkbox_manual_PBL(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
% find existing line
handles.line_manual_pbl = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl');
handles.line_manual_pbl_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad');


if(ishandle(handles.line_manual_pbl))
    if(get(hObj,'Value'))
        set(handles.line_manual_pbl,'Visible','on');
    else
        set(handles.line_manual_pbl,'Visible','off');
    end
end;
if(ishandle(handles.line_manual_pbl_grad))
    if(get(hObj,'Value'))
        set(handles.line_manual_pbl_grad,'Visible','on');
    else
        set(handles.line_manual_pbl_grad,'Visible','off');
    end
end

end