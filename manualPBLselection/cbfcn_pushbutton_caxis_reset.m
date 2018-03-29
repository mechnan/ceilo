function cbfcn_pushbutton_caxis_reset(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.edit_C0 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0');
handles.edit_C1 = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1');

handles.popupmenu_display1_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display1_var');
switch get(handles.popupmenu_display1_var,'Value')
    case 1
        clims = [getappdata(mainObj,'C0_var1_0') getappdata(mainObj,'C1_var1_0')];
        setappdata(mainObj,'C0_var1',clims(1));
        setappdata(mainObj,'C1_var1',clims(2));
    case 2
        clims = [getappdata(mainObj,'C0_var2_0') getappdata(mainObj,'C1_var2_0')];
        setappdata(mainObj,'C0_var2',clims(1));
        setappdata(mainObj,'C1_var2',clims(2));
    otherwise
        return
end

set(handles.edit_C0,'String',clims(1));
set(handles.edit_C1,'String',clims(2));

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
caxis(handles.axes_surface,clims);
axes(handles.axes_surface);

end