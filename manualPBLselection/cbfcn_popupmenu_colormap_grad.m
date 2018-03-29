function cbfcn_popupmenu_colormap_grad(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
handles.popupmenu_colormap_grad = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_colormap_grad');
contents = cellstr(get(handles.popupmenu_colormap_grad,'String'));
colormap_str = contents{get(handles.popupmenu_colormap_grad,'Value')};

load([colormap_str '.mat'],'cmap');
colormap(handles.axes_surface_grad,cmap);

axes(handles.axes_surface_grad);

end