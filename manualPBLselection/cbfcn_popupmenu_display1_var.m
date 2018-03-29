function cbfcn_popupmenu_display1_var(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.edit_C0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0');
handles.edit_C1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1');
handles.popupmenu_display1_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display1_var');
switch get(handles.popupmenu_display1_var,'Value')
    case 1
        set(handles.edit_C0,'String',num2str(getappdata(mainObj,'C0_var1')));
        set(handles.edit_C1,'String',num2str(getappdata(mainObj,'C1_var1')));
    case 2
        set(handles.edit_C0,'String',num2str(getappdata(mainObj,'C0_var2')));
        set(handles.edit_C1,'String',num2str(getappdata(mainObj,'C1_var2')));
    otherwise
        return
end

update_avg;

axes(handles.axes_surface);