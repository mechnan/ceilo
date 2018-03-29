% Read ceilometer data from Roveredo station
% Y. Poltera 2018

% read_ceilo_from_url(datenum(2018,01,14),'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/')

function ceilo = read_ceilo_from_url(list_dates,root_url)

ceilo = struct;
ceilo.name = 'Roveredo';
ceilo.lon = 9.11436;
ceilo.lat = 46.23049;
ceilo.alt = 291;
ceilo.zenith = 0;
ceilo.azimuth = 0;
[ceilo.time,ceilo.range] = deal([]);
ceilo.RCS = NaN(770,0);
ceilo.basedate = NaN(length(list_dates),1);
ceilo.cbh = NaN(3,0);
ceilo.cbhtime = [];
ceilo.cbhdetectionstatus = [];
ceilo.cbhbasedate = NaN(length(list_dates),1);

for jj=1:length(list_dates)
    
    if true
    url = [root_url 'Ceilo' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
    if list_dates(jj)==datenum(2018,1,9)
        url = [root_url '' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
    end

    % load correction functions
    load('correctionNew.mat','correction');
    % correction = ones(244,1);
    load('fcNew.mat','fcNew');fcNew1 = fcNew;
    load('fcNew2.mat','fcNew');fcNew2 = fcNew;
%     fcNew2(18) = 0.8*fcNew2(18);
%     fcNew2(36) = 0.8*fcNew2(36);
%     fcNew2(56) = 0.8*fcNew2(56);
%     fcNew2(74) = 0.8*fcNew2(74);
%     fcNew2(5) = 0.0036825/0.003641*fcNew2(5);
%     fcNew2(5) = 4.85/6.17*fcNew2(5);
%     fcNew2(6) = 4.81/5.23*fcNew2(6);
    fcNew3 = ones(size(fcNew2));
    fcNew3(1) = 1.022;
    % fcNew3(5) =  0.944;
    fcNew3(5) =  0.975;
    fcNew3(6) = 0.981;

    [str,status] = urlread(url);
    if status == 0
       if exist(url,'file')
           disp(url);
           fid = fopen(url);
           cscan = textscan(fid,'%s %s %s',1);
           str = cell2mat([cscan{1} ' ' cscan{2} ' ' cscan{3}]);
           frewind(fid);
           cscan_mat=cell2mat(textscan(fid,['%*[S] %f ' repmat('%f ',1,244) '%*[E]'],'HeaderLines',1,'Whitespace','\r\n'));
           fclose(fid);
           status = 1;
       end
    else
        disp(url);
        cscan_mat=cell2mat(textscan(str,['%*[S] %f ' repmat('%f ',1,244) '%*[E]'],'HeaderLines',1,'Whitespace','\r\n'));
    end
    
    if status~=0
%         disp(url);
%         cscan_mat=cell2mat(textscan(str,['%*[S] %f ' repmat('%f ',1,244) '%*[E]'],'HeaderLines',1,'Whitespace','\r\n'));
        time = cscan_mat(:,1)'/3600/24+365;
        matrix = cscan_mat(:,2:end)';
        ceilo.basedate(jj) = datenum(str(18:36),'dd.mm.yyyy HH:MM:SS');

        %1. Signal Korrektur
        matrix_corr1 = matrix./repmat(correction,1,size(matrix,2));

        %Echtl�ngen reskalieren:
        skala10=matrix_corr1(1:50,:);
        skala20=matrix_corr1(51:100,:);
        skala30=matrix_corr1(101:150,:);
        skala50=matrix_corr1(151:244,:);
        rescale20=NaN(100,size(matrix,2));
        rescale30=NaN(150,size(matrix,2));
        rescale50=NaN(470,size(matrix,2));
        for c=1:size(matrix,2)
            aa=-1;
            b=0;
            d=-2;
            e=0;
            f=-4;
            g=0;
            for count1=1:50
                aa=aa+2;
                b=b+2;
                d=d+3;
                e=e+3;
                rescale20(aa:b,c)=skala20(count1,c);
                rescale30(d:e,c)=skala30(count1,c);
            end
            for count2=1:94
                f=f+5;
                g=g+5;
                rescale50(f:g,c)=skala50(count2,c);
            end
        end
        matrix_resc = vertcat(skala10,rescale20,rescale30,rescale50);
        
        %2. Signal Korrektur
        matrix_corr2 = matrix_resc.*repmat(fcNew1.*fcNew2.*fcNew3,1,size(matrix_resc,2));
        
        ceilo.RCS(:,end+1:end+size(matrix_corr2,2)) = matrix_corr2;
        ceilo.time(end+1:end+length(time)) = time;
        ceilo.range = 10*(1:size(ceilo.RCS,1))';
    else
        disp(['Unable to read '  url '...']);
    end
    
    
    url = [root_url 'CeiloStatus' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
    if list_dates(jj)==datenum(2018,1,9)
        url = [root_url 'Status' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
    end

    [str,status] = urlread(url);
    
    if status == 0
       if exist(url,'file')
           disp(url);
           fid = fopen(url);
           cscan = textscan(fid,'%s %s %s',1);
           str = cell2mat([cscan{1} ' ' cscan{2} ' ' cscan{3}]);
           frewind(fid);
           cscan = textscan(fid,['%f %d%*[W] %d %d %d'],'HeaderLines',1,'TreatAsEmpty','/////','Delimiter',' ,','EmptyValue',-99999);
           fclose(fid);
           status = 1;
       end
    else
        disp(url);
        cscan = textscan(str,['%f %d%*[W] %d %d %d'],'HeaderLines',1,'TreatAsEmpty','/////','Delimiter',' ,','EmptyValue',-99999);
    end
    
    if status~=0
%         disp(url);
%         cscan = textscan(str,['%f %d%*[W] %d %d %d'],'HeaderLines',1,'TreatAsEmpty','/////','Delimiter',' ,','EmptyValue',-99999);
        cbhtime = cscan{1}/3600/24+365;
        ceilo.cbh(:,end+1:end+length(cbhtime)) = [cscan{3},cscan{4},cscan{5}]';
        ceilo.cbhtime(end+1:end+length(cbhtime)) = cbhtime;
        ceilo.cbhdetectionstatus(end+1:end+length(cbhtime)) = cscan{2};
        % 0: no_significant_backscatter
        % 1: one_cloud_base_detected
        % 2: two_cloud_bases_detected
        % 3: three_cloud_bases_detected
        % 4: full_obscuration_determined_but_no_cloud_base_detected
        % 5: some_obscuration_detected_but_determined_to_be_transparent
        % /: raw_data_input_to_algorithm_missing_or_suspect
        ceilo.cbhbasedate(jj) = datenum(str(18:36),'dd.mm.yyyy HH:MM:SS');
    else
        disp(['Unable to read '  url '...']);
    end
    
end

%figure;CL=0.475*7.5e-5*1e-6;imagesc(log10(abs(ceilo.RCS*CL*1e6)),log10([0.17812 2.375]));  %Farbskala kann variiert werden
%axis xy;colormap(jet);colorbar;
%ylim([0 400]);

end