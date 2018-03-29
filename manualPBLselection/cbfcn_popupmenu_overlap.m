function cbfcn_popupmenu_overlap(hObj,eventdata)

%get gui figure
mainObj = gcbf;

handles.edit_date = findobj(mainObj,'Type','uicontrol','Style','edit','Tag','edit_date');
date = get(handles.edit_date,'String');

handles.popupmenu_station = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_station');
contents = cellstr(get(handles.popupmenu_station,'String'));
station = contents{get(handles.popupmenu_station,'Value')};

% if isunix
%     root_folder = '/data/pay/PBL4EMPA/overlap_correction/overlap_functions_Lufft/';
% else
%     root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\overlap_correction\overlap_functions_Lufft\';    
% end
root_folder = getappdata(mainObj,'overlap_functions_Lufft_path');

ovp_manufacturer = [];
fname_overlapfc = '';
if strcmp(station,'pay')
    if datenum(date,'yyyymmdd')<datenum(2015,03,04)
        fname_overlapfc = fullfile([root_folder,'TUB120011_20121112_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    else
        fname_overlapfc = fullfile([root_folder,'TUB140007_20150126_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    end
    
elseif strcmp(station,'kse')
        fname_overlapfc = fullfile([root_folder,'TUB140005_20140515_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end

elseif strcmp(station,'sirta')
        fname_overlapfc = fullfile([root_folder,'TUB140013_20150211_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
        
elseif strcmp(station,'granada')
        fname_overlapfc = fullfile([root_folder,'TUB120012_20120917_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
        
elseif strcmp(station,'lindenberg')
    if datenum(date,'yyyymmdd')<datenum(2012,09,17)
        fname_overlapfc = fullfile([root_folder,'TUB120001_20120125_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    else
        fname_overlapfc = fullfile([root_folder,'TUB120001_20120917_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    end
    
elseif strcmp(station,'lindenberg_chm100110')
    if datenum(date,'yyyymmdd')<datenum(2012,09,17)
        fname_overlapfc = fullfile([root_folder,'TUB120001_20120125_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    else
        fname_overlapfc = fullfile([root_folder,'TUB120001_20120917_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
    end
    
        
elseif strcmp(station,'lindenberg_chm140101')

elseif strcmp(station,'lindenberg_chx080082')
 
elseif strcmp(station,'lindenberg_chx090103')

elseif strcmp(station,'hamburg')
        fname_overlapfc = fullfile([root_folder,'TUB100011_20121214_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
        
elseif strcmp(station,'hohenpeissenberg')
        fname_overlapfc = fullfile([root_folder,'TUB070009_20111012_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
        
elseif strcmp(station,'oslo')
    
elseif strcmp(station,'flesland')
        fname_overlapfc = fullfile([root_folder,'TUB140002_20140429_1024.cfg']);
        if exist(fname_overlapfc,'file')==2
            fid = fopen(fname_overlapfc);
            ov_cell = textscan(fid, '%f','headerLines',1);
            fclose(fid);
            ovp_manufacturer = cell2mat(ov_cell);
        end
        
elseif strcmp(station,'macehead')
        
end

handles.popupmenu_overlap = findobj(mainObj,'Type','uicontrol','Style','popupmenu','Tag','popupmenu_overlap');
switch get(handles.popupmenu_overlap,'Value')
    case 1
        if isappdata(mainObj,'chm15k_beta_raw_0_0')
            setappdata(mainObj,'chm15k_beta_raw_0',getappdata(mainObj,'chm15k_beta_raw_0_0'));
            setappdata(mainObj,'RVS_var_0',getappdata(mainObj,'RVS_var_0_0'));
        end
        handles.text_overlap = findobj(mainObj,'Type','uicontrol','Style','text','Tag','text_overlap');
        [pathstr,name,ext] = fileparts(fname_overlapfc);
        set(handles.text_overlap,'String',[name,ext]);

    case 2
%         if isunix
%             root_folder = '/data/pay/PBL4EMPA/overlap_correction/manualPBLselection/overlap_functions/';
%         else
%             root_folder = '\\meteoswiss.ch\mch\pay-data\data\pay\PBL4EMPA\overlap_correction\manualPBLselection\overlap_functions\';
%         end
        root_folder = getappdata(mainObj,'overlap_functions_path');
        
        handles.text_overlap = findobj(mainObj,'Type','uicontrol','Style','text','Tag','text_overlap');
                    
        if ~getappdata(mainObj,'donotaskforoverlap');
%             [filename,path] = uigetfile([root_folder station '_*.mat'], 'Select an overlap function','MultiSelect','off');
            [filename,path] = uigetfile([root_folder '*.mat'], 'Select an overlap function','MultiSelect','off');
            if(filename==0)
                warning('No file selected');
                return;
            end
        else
            filename = get(handles.text_overlap,'String');
            path = root_folder;
        end
        disp(fullfile(path,filename));
        try
            ovdat = load(fullfile(path,filename));
            names = fieldnames(ovdat);
            ovp_fc = getfield(ovdat,names{1});
        catch
            errordlg('Unable to load overlap function');
            return;
        end

        set(handles.text_overlap,'String',filename);

        if isappdata(mainObj,'chm15k_beta_raw_0_0')
            chm15k.beta_raw_0_0 = getappdata(mainObj,'chm15k_beta_raw_0_0');
            RCS_var_0_0 = getappdata(mainObj,'RCS_var_0_0');
            
            if isempty(ovp_manufacturer)
                ovp_manufacturer = ones(size(chm15k.beta_raw_0_0,1),1);
                warning('no manufacturer overlap')
            end
            factor = repmat(ovp_manufacturer,1,size(chm15k.beta_raw_0_0,2))./repmat(ovp_fc,1,size(chm15k.beta_raw_0_0,2));

            chm15k.beta_raw_0 = chm15k.beta_raw_0_0 .* factor;
            RCS_var_0 = RCS_var_0_0 .* (factor.^2);

            setappdata(mainObj,'chm15k_beta_raw_0',chm15k.beta_raw_0);
            setappdata(mainObj,'RVS_var_0',RCS_var_0);
        end
        
    otherwise
        return
end

update_avg;

end