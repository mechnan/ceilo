function cbfcn_checkbox_manual_PBL_view(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
% find existing line
handles.line_manual_pbl_view = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl_view');
handles.line_manual_pbl_grad_view = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad_view');

if(ishandle(handles.line_manual_pbl_view))
    if(get(hObj,'Value'))
        set(handles.line_manual_pbl_view,'Visible','on');
    else
        set(handles.line_manual_pbl_view,'Visible','off');
    end
end;
if(ishandle(handles.line_manual_pbl_grad_view))
    if(get(hObj,'Value'))
        set(handles.line_manual_pbl_grad_view,'Visible','on');
    else
        set(handles.line_manual_pbl_grad_view,'Visible','off');
    end
end

end