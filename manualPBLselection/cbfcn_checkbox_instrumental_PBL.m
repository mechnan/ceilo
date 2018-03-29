function cbfcn_checkbox_instrumental_PBL(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

% find existing lines
handles.line_CBL_PM = findobj(handles.axes_surface,'Type','line','Tag','line_CBL_PM');
if(ishandle(handles.line_CBL_PM))
    if(get(hObj,'Value'))
        set(handles.line_CBL_PM,'Visible','on');
    else
        set(handles.line_CBL_PM,'Visible','off');
    end
end;
handles.line_CBL_PM_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_PM_grad');
if(ishandle(handles.line_CBL_PM_grad))
    if(get(hObj,'Value'))
        set(handles.line_CBL_PM_grad,'Visible','on');
    else
        set(handles.line_CBL_PM_grad,'Visible','off');
    end
end;  
handles.line_CBL_PM_RS= findobj(handles.axes_surface,'Type','line','Tag','line_CBL_PM_RS');
if(ishandle(handles.line_CBL_PM_RS))
    if(get(hObj,'Value'))
        set(handles.line_CBL_PM_RS,'Visible','on');
    else
        set(handles.line_CBL_PM_RS,'Visible','off');
    end
end;
handles.line_CBL_PM_RS_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_PM_RS_grad');
if(ishandle(handles.line_CBL_PM_RS_grad))
    if(get(hObj,'Value'))
        set(handles.line_CBL_PM_RS_grad,'Visible','on');
    else
        set(handles.line_CBL_PM_RS_grad,'Visible','off');
    end
end; 
handles.line_CBL_bR = findobj(handles.axes_surface,'Type','line','Tag','line_CBL_bR');
if(ishandle(handles.line_CBL_bR))
    if(get(hObj,'Value'))
        set(handles.line_CBL_bR,'Visible','on');
    else
        set(handles.line_CBL_bR,'Visible','off');
    end
end;
handles.line_CBL_bR_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_bR_grad');
if(ishandle(handles.line_CBL_bR_grad))
    if(get(hObj,'Value'))
        set(handles.line_CBL_bR_grad,'Visible','on');
    else
        set(handles.line_CBL_bR_grad,'Visible','off');
    end
end;
handles.line_CBL_bR_RS= findobj(handles.axes_surface,'Type','line','Tag','line_CBL_bR_RS');
if(ishandle(handles.line_CBL_bR_RS))
    if(get(hObj,'Value'))
        set(handles.line_CBL_bR_RS,'Visible','on');
    else
        set(handles.line_CBL_bR_RS,'Visible','off');
    end
end;
handles.line_CBL_bR_RS_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_CBL_bR_RS_grad');
if(ishandle(handles.line_CBL_bR_RS_grad))
    if(get(hObj,'Value'))
        set(handles.line_CBL_bR_RS_grad,'Visible','on');
    else
        set(handles.line_CBL_bR_RS_grad,'Visible','off');
    end
end;
handles.line_SBL = findobj(handles.axes_surface,'Type','line','Tag','line_SBL');
if(ishandle(handles.line_SBL))
    if(get(hObj,'Value'))
        set(handles.line_SBL,'Visible','on');
    else
        set(handles.line_SBL,'Visible','off');
    end
end;
handles.line_SBL_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_SBL_grad');
if(ishandle(handles.line_SBL_grad))
    if(get(hObj,'Value'))
        set(handles.line_SBL_grad,'Visible','on');
    else
        set(handles.line_SBL_grad,'Visible','off');
    end
end;  
handles.line_SBL_RS= findobj(handles.axes_surface,'Type','line','Tag','line_SBL_RS');
if(ishandle(handles.line_SBL_RS))
    if(get(hObj,'Value'))
        set(handles.line_SBL_RS,'Visible','on');
    else
        set(handles.line_SBL_RS,'Visible','off');
    end
end;
handles.line_SBL_RS_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_SBL_RS_grad');
if(ishandle(handles.line_SBL_RS_grad))
    if(get(hObj,'Value'))
        set(handles.line_SBL_RS_grad,'Visible','on');
    else
        set(handles.line_SBL_RS_grad,'Visible','off');
    end
end;
handles.line_Tinv= findobj(handles.axes_surface,'Type','line','Tag','line_Tinv');
if(ishandle(handles.line_Tinv))
    if(get(hObj,'Value'))
        set(handles.line_Tinv,'Visible','on');
    else
        set(handles.line_Tinv,'Visible','off');
    end
end;
handles.line_Tinv_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_Tinv_grad');
if(ishandle(handles.line_Tinv_grad))
    if(get(hObj,'Value'))
        set(handles.line_Tinv_grad,'Visible','on');
    else
        set(handles.line_Tinv_grad,'Visible','off');
    end
end;
handles.line_Tinv_RS= findobj(handles.axes_surface,'Type','line','Tag','line_Tinv_RS');
if(ishandle(handles.line_Tinv_RS))
    if(get(hObj,'Value'))
        set(handles.line_Tinv_RS,'Visible','on');
    else
        set(handles.line_Tinv_RS,'Visible','off');
    end
end;
handles.line_Tinv_RS_grad= findobj(handles.axes_surface_grad,'Type','line','Tag','line_Tinv_RS_grad');
if(ishandle(handles.line_Tinv_RS_grad))
    if(get(hObj,'Value'))
        set(handles.line_Tinv_RS_grad,'Visible','on');
    else
        set(handles.line_Tinv_RS_grad,'Visible','off');
    end
end; 


end