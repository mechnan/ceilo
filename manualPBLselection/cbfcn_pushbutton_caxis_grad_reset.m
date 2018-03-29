function cbfcn_pushbutton_caxis_grad_reset(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.edit_C0_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0_grad');
handles.edit_C1_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1_grad');

handles.popupmenu_display2_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display2_var');
switch get(handles.popupmenu_display2_var,'Value')
    case 1
        clims = [getappdata(mainObj,'C0_grad_var1_0') getappdata(mainObj,'C1_grad_var1_0')];
        setappdata(mainObj,'C0_grad_var1',clims(1));
        setappdata(mainObj,'C1_grad_var1',clims(2));
    case 2
        clims = [getappdata(mainObj,'C0_grad_var2_0') getappdata(mainObj,'C1_grad_var2_0')];
        setappdata(mainObj,'C0_grad_var2',clims(1));
        setappdata(mainObj,'C1_grad_var2',clims(2));
    otherwise
        return
end

set(handles.edit_C0_grad,'String',clims(1));
set(handles.edit_C1_grad,'String',clims(2));

handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
caxis(handles.axes_surface_grad,clims);
axes(handles.axes_surface_grad);

end