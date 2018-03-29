function cbfcn_edit_C01_grad(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
handles.edit_C0_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0_grad');
handles.edit_C1_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1_grad');
clims = [str2double(get(handles.edit_C0_grad,'String')) str2double(get(handles.edit_C1_grad,'String'))];
caxis(handles.axes_surface_grad,clims);

handles.popupmenu_display2_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display2_var');
switch get(handles.popupmenu_display2_var,'Value')
    case 1
        setappdata(mainObj,'C0_grad_var1',clims(1));
        setappdata(mainObj,'C1_grad_var1',clims(2));
    case 2
        setappdata(mainObj,'C0_grad_var2',clims(1));
        setappdata(mainObj,'C1_grad_var2',clims(2));
    otherwise
        return
end

axes(handles.axes_surface_grad);

end