function cbfcn_pushbutton_manualPBL_save(hObj,eventdata)

%get gui figure and app data
mainObj = gcbf;

%get axes container
parentObj = findobj(mainObj,'Type','axes','Tag','axes_surface');

% find existing line
handles.line_manual_pbl = findobj(parentObj,'Type','scatter','Tag','line_manual_pbl');
if(ishandle(handles.line_manual_pbl))
    xdata = get(handles.line_manual_pbl,'XData');
    ydata = get(handles.line_manual_pbl,'YData');
    zdata = get(handles.line_manual_pbl,'ZData');
    
    [t,isort] = sort(xdata);
    manual_pbl.t = t;
    manual_pbl.pblh = ydata(isort);
    manual_pbl.pbltype = zdata(isort);
    
    handles.popupmenu_station = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_station');
    contents = cellstr(get(handles.popupmenu_station,'String'));
    station = contents{get(handles.popupmenu_station,'Value')};
    
    handles.edit_date = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_date');
    date = get(handles.edit_date,'String');
    
    handles.edit_accronym = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_accronym');
    accronym = get(handles.edit_accronym,'String');
    
%     if isunix
%         root_folder = '/data/pay/PBL4EMPA/pbl_analysis/manual_PBL/';
%     else
%         root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\pbl_analysis\manual_PBL\';
%     end
    root_folder = getappdata(mainObj,'manual_PBL_path');
    
    [filename,path] = uiputfile([root_folder station '_' date '_' accronym '.mat'], 'Choose where to save');
    save([path,filename],'manual_pbl');
else
    errordlg('no data to save');
    return;
end

axes(parentObj);

end