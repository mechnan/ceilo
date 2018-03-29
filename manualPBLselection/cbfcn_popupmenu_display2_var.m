function cbfcn_popupmenu_display2_var(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
handles.edit_C0_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C0_grad');
handles.edit_C1_grad = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_C1_grad');
handles.popupmenu_display2_var = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_display2_var');
switch get(handles.popupmenu_display2_var,'Value')
    case 1
        set(handles.edit_C0_grad,'String',num2str(getappdata(mainObj,'C0_grad_var1')));
        set(handles.edit_C1_grad,'String',num2str(getappdata(mainObj,'C1_grad_var1')));
    case 2
        set(handles.edit_C0_grad,'String',num2str(getappdata(mainObj,'C0_grad_var2')));
        set(handles.edit_C1_grad,'String',num2str(getappdata(mainObj,'C1_grad_var2')));
    otherwise
        return
end

update_avg;

axes(handles.axes_surface_grad);