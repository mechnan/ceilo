function cbfcn_pushbutton_manualPBL_view(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
handles.axes_surface = findobj(mainObj,'Type','axes','Tag','axes_surface');
handles.axes_surface_grad = findobj(mainObj,'Type','axes','Tag','axes_surface_grad');
% find existing line
handles.line_manual_pbl_view = findobj(handles.axes_surface,'Type','scatter','Tag','line_manual_pbl_view');
handles.line_manual_pbl_grad_view = findobj(handles.axes_surface_grad,'Type','scatter','Tag','line_manual_pbl_grad_view');
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

[filenames,path] = uigetfile([root_folder station '_' date '*.mat'], 'Select manual PBL files','MultiSelect','on');

if(~iscell(filenames))
    if(filenames==0)
        warning('No file selected');
        return;
    end
    if ischar(filenames)
        filenames = {filenames};
    end
end

accronym_list = {'haa','gim','hem','poy'};
accronym_color = {[0.75 0.75 0.75],[0.5 0.5 1],[1 0.5 0.25],[1 0 0.5]};

x = [];
y = [];
z = [];
c = NaN(0,3);
for k=1:length(filenames)
    
    color_file = [1 1 1];
    for l=1:length(accronym_list)
        if ~isempty(strfind(filenames{k},accronym_list{l}))
            color_file = accronym_color{l};
            break;
        end
    end

    disp(fullfile(path,filenames{k}));
    load(fullfile(path,filenames{k}),'manual_pbl');
    
    x = [x,manual_pbl.t];
    y = [y,manual_pbl.pblh];
    if isfield(manual_pbl,'pbltype')
        z = [z,manual_pbl.pbltype];
    else
        z = [z,ones(1,length(manual_pbl.t))];
    end
    
%     color_tag = {[0 0 0],[1 1 0],[0 1 1]};
    ctmp = NaN(length(manual_pbl.t),3);
    for j=1:length(manual_pbl.t)
%        ctmp(j,:) = color_tag{z(j)}; 
        ctmp(j,:) = color_file;
    end
    c = [c;ctmp];
    
end

if(ishandle(handles.line_manual_pbl_view))
    delete(handles.line_manual_pbl_view);
end;
if(ishandle(handles.line_manual_pbl_grad_view))
    delete(handles.line_manual_pbl_grad_view);
end
    
handles.checkbox_manual_PBL_view = findobj(mainObj,'Type','uicontrol','Style','checkbox','Tag','checkbox_manual_PBL_view');
if get(handles.checkbox_manual_PBL_view,'Value')
    vis = 'on';
else
    vis = 'off';
end

axes(handles.axes_surface);
hold on;
handles.line_manual_pbl_view = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface ,'Tag','line_manual_pbl_view','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor);

axes(handles.axes_surface_grad);
hold on;
handles.line_manual_pbl_grad_view = scatter(x,y,'Marker','o','MarkerFaceColor','flat','SizeData',24,'Parent',handles.axes_surface_grad,'Tag','line_manual_pbl_grad_view','ZData',z,'CData',c,'Visible',vis,'ButtonDownFcn',@bdfcn_surface_pcolor_grad);


end
