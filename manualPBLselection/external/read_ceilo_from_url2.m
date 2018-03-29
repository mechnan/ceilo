% Read ceilometer data from Roveredo station
% Y. Poltera 2018
function ceilo = read_ceilo_from_url2(list_dates,root_url)

ceilo = struct;
ceilo.name = 'Roveredo';
ceilo.lon = 9.11436;
ceilo.lat = 46.23049;
ceilo.alt = 291;
ceilo.zenith = 0;
ceilo.azimuth = 0;
ceilo.CL = 1.425*0.75*0.475*7.5e-5*1e-6;

% pre-allocate arrays
ceilo.range = (10:10:7700)';
ceilo.time = NaN(1440*length(list_dates),1);
% ceilo.RCS = NaN(770,1440*length(list_dates));
RCSraw = NaN(244,1440*length(list_dates));
ceilo.basedate = NaN(length(list_dates),1);
ceilo.cbh = NaN(3,43200*length(list_dates));
ceilo.cbhtime = NaN(43200*length(list_dates),1);
ceilo.cbhdetectionstatus = NaN(43200*length(list_dates),1);
ceilo.cbhbasedate = NaN(length(list_dates),1);


for jj=1:length(list_dates)
    
        url = [root_url 'Ceilo' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
        if list_dates(jj)==datenum(2018,1,9)
            url = [root_url '' num2str(floor(list_dates(jj)-datenum(2018,1,1)+1)) '.dat'];
        end

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

%             time = cscan_mat(:,1)'/3600/24+365;
%             matrix = cscan_mat(:,2:end)';
            ceilo.basedate(jj) = datenum(str(18:36),'dd.mm.yyyy HH:MM:SS');

%             ceilo.RCS(:,(jj-1)*1440+1:(jj-1)*1440+size(matrix_resc,2)) = matrix_resc;
            ceilo.time((jj-1)*1440+1:(jj-1)*1440+size(cscan_mat,1)) = cscan_mat(:,1)'/3600/24+365;
%             ceilo.range = 10*(1:size(ceilo.RCS,1))';
            RCSraw(:,(jj-1)*1440+1:(jj-1)*1440+size(cscan_mat,1)) = cscan_mat(:,2:end)';
            
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
            ceilo.cbhbasedate(jj) = datenum(str(18:36),'dd.mm.yyyy HH:MM:SS');
%             cbhtime = cscan{1}/3600/24+365;
            ceilo.cbhtime((jj-1)*43200+1:(jj-1)*43200+length(cscan{1})) = cscan{1}/3600/24+365;
            ceilo.cbhdetectionstatus((jj-1)*43200+1:(jj-1)*43200+length(cscan{1})) = cscan{2};
            % 0: no_significant_backscatter
            % 1: one_cloud_base_detected
            % 2: two_cloud_bases_detected
            % 3: three_cloud_bases_detected
            % 4: full_obscuration_determined_but_no_cloud_base_detected
            % 5: some_obscuration_detected_but_determined_to_be_transparent
            % /: raw_data_input_to_algorithm_missing_or_suspect
            ceilo.cbh(:,(jj-1)*43200+1:(jj-1)*43200+length(cscan{1})) = [cscan{3},cscan{4},cscan{5}]';
            

        else
            disp(['Unable to read '  url '...']);
        end
        
    
%     figure;CL=0.75*0.475*7.5e-5*1e-6;imagesc(log10(abs(ceilo.RCS*CL*1e6)),log10([0.1 2]));  %Farbskala kann variiert werden
%     axis xy;colormap(jet);colorbar;
    
end

% Remove empty values
indok = isfinite(ceilo.time);
% ceilo.RCS = ceilo.RCS(:,indok);
RCSraw = RCSraw(:,indok);
ceilo.time = ceilo.time(indok);

indok = isfinite(ceilo.cbhtime);
ceilo.cbh = ceilo.cbh(:,indok);
ceilo.cbhdetectionstatus = ceilo.cbhdetectionstatus(indok);
ceilo.cbhtime = ceilo.cbhtime(indok);

% 1. Echtlängen reskalieren

ceilo.RCS = NaN(770,size(RCSraw,2));
ceilo.RCS(1:1:50,:) = RCSraw(1:50,:);
ceilo.RCS([51:2:149,52:2:150],:) = repmat(RCSraw(51:100,:),2,1);
ceilo.RCS([151:3:298,152:3:299,153:3:300],:) = repmat(RCSraw(101:150,:),3,1);
ceilo.RCS([301:5:766,302:5:767,303:5:768,304:5:769,305:5:770],:) = repmat(RCSraw(151:244,:),5,1);

% 2. Signal Korrektur

% load correction functions
load('fcNew0.mat','fcNew');fcNew0 = fcNew;
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
fcNew3(5) =  0.975;fcNew3(5) = 1.015;
fcNew3(6) = 0.981;fcNew3(6) = 1.015;
load('fcNew4.mat','fcNew');fcNew4 = fcNew;

ceilo.RCS = ceilo.RCS.*repmat(fcNew0.*fcNew1.*fcNew2.*fcNew3,1,size(ceilo.RCS,2));
corr = 1+(repmat(fcNew4,1,size(ceilo.RCS,2))-1).*max(1+5*(0.225-(ceilo.RCS*0.75*0.475*7.5e-5)),0);
ceilo.RCS = corr.*ceilo.RCS;

% ceilo.iscloudfree = NaN(1,length(ceilo.time));
% ctime = [-Inf;ceilo.time];
% for i=2:length(ctime)
%     indt = ceilo.cbhtime>ctime(i-1) & ceilo.cbhtime<=ctime(i);
%     ceilo.iscloudfree(i-1) = ~any(ceilo.cbhdetectionstatus(indt)~=0);
% end