function cbfcn_popupmenu_colormap(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.popupmenu_colormap = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_colormap');
contents = cellstr(get(handles.popupmenu_colormap,'String'));
colormap_str = contents{get(handles.popupmenu_colormap,'Value')};

load([colormap_str '.mat'],'cmap');
colormap(handles.axes_surface,cmap);

axes(handles.axes_surface);

end