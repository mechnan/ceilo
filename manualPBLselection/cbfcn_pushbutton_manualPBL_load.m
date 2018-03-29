function cbfcn_pushbutton_manualPBL_load(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
% find existing line
handles.line_manual_pbl = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl');
handles.line_manual_pbl_grad = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad');
% find station
handles.popupmenu_station = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_station');
contents = cellstr(get(handles.popupmenu_station,'String'));
station = contents{get(handles.popupmenu_station,'Value')};
% find date
handles.edit_date = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_date');
date = get(handles.edit_date,'String');

% if isunix
%     root_folder = '/data/pay/PBL4EMPA/pbl_analysis/manual_PBL/';
% else
%     root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\pbl_analysis\manual_PBL\';
% end
root_folder = getappdata(mainObj,'manual_PBL_path');

[filename,path] = uigetfile([root_folder station '_' date '*.mat'], 'Select a manual PBL','MultiSelect','off');

if(filename==0)
    warning('No file selected');
    return;
else
    disp(fullfile(path,filename));
    load(fullfile(path,filename),'manual_pbl');
    
    if(ishandle(handles.line_manual_pbl))
        delete(handles.line_manual_pbl);
    end;
    if(ishandle(handles.line_manual_pbl_grad))
        delete(handles.line_manual_pbl_grad);
    end
    
    x = manual_pbl.t;
    y = manual_pbl.pblh;
    if isfield(manual_pbl,'pbltype')
        z = manual_pbl.pbltype;
    else
        z = ones(length(x),1);
    end
    
    color_tag = {[0 0 0],[1 1 0],[0 1 1]};
    c = NaN(length(x),3);
    for j=1:length(x)
       c(j,:) = color_tag{z(j)}; 
    end
    
    handles.checkbox_manual_PBL = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_manual_PBL');
    if get(handles.checkbox_manual_PBL,'Value')
        vis = 'on';
    else
        vis = 'off';
    end

    axes(handles.axes_surface);
    hold on;
    handles.line_manual_pbl = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface ,'Tag','line_manual_pbl','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_line_manual_pbl);

    axes(handles.axes_surface_grad);
    hold on;
    handles.line_manual_pbl_grad = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface_grad,'Tag','line_manual_pbl_grad','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_line_manual_pbl_grad);


end

end
