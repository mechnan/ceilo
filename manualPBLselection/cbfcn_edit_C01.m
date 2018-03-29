function cbfcn_edit_C01(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.edit_C0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0');
handles.edit_C1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1');
clims = [str2double(get(handles.edit_C0,'String')) str2double(get(handles.edit_C1,'String'))];
caxis(handles.axes_surface,clims);

handles.popupmenu_display1_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display1_var');
switch get(handles.popupmenu_display1_var,'Value')
    case 1
        setappdata(mainObj,'C0_var1',clims(1));
        setappdata(mainObj,'C1_var1',clims(2));
    case 2
        setappdata(mainObj,'C0_var2',clims(1));
        setappdata(mainObj,'C1_var2',clims(2));
    otherwise
        return
end

axes(handles.axes_surface);

end