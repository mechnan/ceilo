function cbfcn_checkbox_SBL(hObj,eventdata)

mainObj = gcbf;

handles.checkbox_SBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_SBL');

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');

hObj = handles.checkbox_SBL;

%delete already existing line
handles.line_SBL = findobj(handles.axes_surface,'Type','line','Tag','line_SBL');
if(ishandle(handles.line_SBL))
    delete(handles.line_SBL);
end;
handles.line_SBL_grad = findobj(handles.axes_surface_grad,'Type','line','Tag','line_SBL_grad');
if(ishandle(handles.line_SBL_grad))
    delete(handles.line_SBL_grad);
end;  

list_plots = [];
list_legends = {};
if(get(hObj,'Value'))
    %draw line
    if isappdata(mainObj,'SBL')
        y =  getappdata(mainObj,'SBL');
        x = getappdata(mainObj,'SBL_t');
        axes(handles.axes_surface);
        
        handles.checkbox_instrumental_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_instrumental_PBL');
        if get(handles.checkbox_instrumental_PBL,'Value')
            vis = 'on';
        else
            vis = 'off';
        end        
                
        handles.line_SBL = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[0.5 0 1],'MarkerSize',4,...
            'Parent',handles.axes_surface,'Tag','line_SBL','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);
        handles.line_SBL_grad = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor',[0.5 0 1],'MarkerSize',4,...
            'Parent',handles.axes_surface_grad,'Tag','line_SBL_grad','Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);
        list_plots(end+1) = handles.line_SBL;
        list_legends{end+1} = {'SBL'};
    end
end

end