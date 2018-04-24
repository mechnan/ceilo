function aerosol_top = get_TCAL(dn)

% root_url = 'C:\Users\yann\Desktop\iacweb.ethz.ch\staff\krieger\data\FS18\Ceilometer\';
root_url = 'http://iacweb.ethz.ch/staff//krieger/data/FS18/Ceilometer/';
 
try
    
tic
ceilo = read_ceilo_from_url(dn,root_url);
toc

%% running mean, running std & rough SNR

RCS_m = movmean(ceilo.RCS,[10,10],2,'omitnan');
RCS_m = movmean(RCS_m,[1,1],1,'omitnan');

[nx,ny] = deal(2*10+1,2*1+1);
RCS_m_cv = conv2(ceilo.RCS,1/prod([nx,ny])*ones(ny,nx),'same');
RCS2_m_cv = conv2(ceilo.RCS.^2,1/prod([nx,ny])*ones(ny,nx),'same');
RCS_std_cv = sqrt(RCS2_m_cv-RCS_m_cv.^2);

SNR = RCS_m_cv./RCS_std_cv;

%% prepare data for TCAL

chm = struct;
chm.zenith = ceilo.zenith;
chm.SNR_2 = SNR;
chm.beta_raw_2 = RCS_m;
chm.time = ceilo.time;
chm.range = ceilo.range;
ov = ones(size(chm.range));
ov(1:5) = 0;

chm.sci = 0*ones(size(chm.time));

chm.cbh = ceilo.cbh;
chm.cbhtime = ceilo.cbhtime;
chm.cho = 0;
chm.cdp = 30*ones(size(ceilo.cbh));
chm.average_time = 60000*ones(size(ceilo.time));% ms

%% determine if bad weather
is_bad_sci = zeros(length(chm.sci),1);
is_bad_sci(chm.sci~=0) = 1;

is_rainy = [];

bad_weather = zeros(size(chm.time));
if ~isempty(is_bad_sci)
    for j=2:length(chm.time)
        indt = chm.time>chm.time(j-1) & chm.time <= chm.time(j) ;
        if is_bad_sci(j)
            if any(indt)
                bad_weather(indt) = 1;
            end
        end
    end
end
if ~isempty(is_rainy)
    for j=2:length(chm.time)
        indt = chm.time>chm.time(j-1) & chm.time <= chm.time(j) ;
        if is_rainy(j)
            if any(indt)
                bad_weather(indt) = 1;
            end
        end
    end
end

%% determine if low clouds
is_low_cloud = zeros(size(chm.time));

cbh = NaN(size(chm.cbh,1),length(chm.time));
cdp = NaN(size(chm.cbh,1),length(chm.time));
for i=1:size(chm.cbh,1)
   cbh0 = chm.cbh(i,:)-chm.cho;cbh0(cbh0<0) = NaN;cbh0 = sind(90-chm.zenith)*cbh0;
   cdp0 = chm.cdp(i,:);cdp0(cdp0<0) = NaN;cdp0 = sind(90-chm.zenith)*cdp0;
   for j=1:length(chm.time)
       indCloud = find(chm.cbhtime>=chm.time(j)-chm.average_time(j)/1000/3600/24 & chm.cbhtime<chm.time(j));
       if ~isempty(indCloud)
           cbh(i,j) = nanmin(cbh0(indCloud));
           cdp(i,j) = nanmax(cdp0(indCloud));
       end
   end
end
is_low_cloud(nanmin(cbh,[],1)<1600) = 1;

%% Calculate TCAL

% 0. determine range of the top (i.e. base+depth) of first layer clouds
lim_cloudr = 1/sind(90-chm.zenith)*(cbh(1,:)+cdp(1,:));
ind_cloud_top = ones(length(lim_cloudr),1);
for j=1:length(lim_cloudr)
    if isnan(lim_cloudr(j))
        ind_cloud_top(j) = length(chm.range);
    else
        ind_top=find(chm.range<=lim_cloudr(j),1,'last');
        if ~isempty(ind_top)
            ind_cloud_top(j)=ind_top;
        end
    end
end

% 1. calculate masks
% SNRlim = 0.6745;%{0.6745, 1, 3}
SNRlim = 3;
maskSNR = (chm.SNR_2>SNRlim).*(chm.beta_raw_2>0);
% % maskSNR(1:find(sind(90-100*chm.zenith)*chm.range<=1600,1,'last'),:)=1;
% maskSNR(:,:) = 1;
snr_lim_top = NaN(length(chm.time),1);

cv_threshold = 4.625;
cv_threshold = log10(0.25 / (ceilo.CL*1e6));
% cv_threshold = log10(0.3 / (ceilo.CL*1e6));
% cv_threshold = log10(0.05*1e-6);

for j=1:3
    ext = [ones(1,length(chm.time)+2);ones(length(chm.range),1),maskSNR,ones(length(chm.range),1);ones(1,length(chm.time)+2)];
    cv = conv2(ext,ones(3,3),'valid');
    maskSNR(cv~=9) = 0;
end
for j=1:20
    cv = conv2(maskSNR,ones(3,3),'same');
    maskSNR(cv>0) = 1;
end

maskUC = maskSNR;
for j=1:length(chm.time)
   null_tmp = cumsum(~maskSNR(:,j));
   one_tmp = cumsum(maskSNR(:,j));
   tmp = one_tmp - null_tmp;
   dtmp = conv(tmp,[1;0;-1],'same');
   d2tmp = conv(dtmp,[1;0;-1],'same');
   ind_p = find((dtmp==0).*(d2tmp<0).*(chm.range>600),1,'first');
   if ~isempty(ind_p)
      maskUC(ind_p+2:end,j) = 0; 
      snr_lim_top(j) = chm.range(ind_p+1);
   end
end

indr0 = find(ov>=0.05,1,'first');

ind_aerosol_top = NaN(size(chm.time));

maskMOL = ones(size(chm.beta_raw_2));
for j=1:length(chm.time)
    cv = conv(log10(abs(chm.beta_raw_2(:,j))),1/11*ones(11,1),'same');
    ind_p = find(cv<cv_threshold & chm.range>=chm.range(indr0),1,'first');
    if ~isempty(ind_p)
        if ind_p>ind_cloud_top(j)
            ind_p = ind_cloud_top(j);
        end
        maskMOL(ind_p:end,j) = 0;
        if ind_p>1
            ind_aerosol_top(j) = ind_p-1;
        end
    end
end

n_erosions = 3;
n_dilations = 10;
for j=1:n_erosions
    ext = [ones(1,length(chm.time)+2);ones(length(chm.range),1),maskMOL,ones(length(chm.range),1);ones(1,length(chm.time)+2)];
    cv = conv2(ext,ones(3,3),'valid');
    maskMOL(cv~=9) = 0;
end
for j=1:n_dilations
    cv = conv2(maskMOL,ones(3,3),'same');
    maskMOL(cv>0) = 1;
end

ind_low_signal = maskMOL(indr0-n_erosions+n_dilations,:) == 0;
maskMOL(:,ind_low_signal) = zeros(size(chm.beta_raw_2,1),sum(ind_low_signal));
% if sum(ind_low_signal)>0
%     for j=1:60
%         cv = conv2(maskMOL,[0 0 0;1 0 1;0 0 0],'same');
%         maskMOL(cv>0) = 1;
%     end
% end

for j=1:length(chm.time)
   ind_last = find(maskMOL(:,j),1,'last');
   if ~isempty(ind_last)
       ind_top = ind_last-floor(10*(1-sind(90-71+1*chm.zenith)));
%        ind_top = ind_last;
       if ind_top>=0
           maskMOL(ind_top+1:end,j) = 0;
       end
   end
end

% 2. take blocks into account

left_blocks = [diff(ind_low_signal)==1,0];
right_blocks = [0,diff(ind_low_signal)==-1];
masktmp = maskMOL;
masktmp(:,~(left_blocks | right_blocks)) = zeros(size(chm.beta_raw_2,1),sum(~(left_blocks | right_blocks)));
masktmp(:,(is_low_cloud>0 | bad_weather>0)) = zeros(size(chm.beta_raw_2,1),sum((is_low_cloud>0 | bad_weather>0)));

if sum(ind_low_signal)>0
    for j=1:20
        cv = conv2(masktmp,[0 0 0;1 0 1;0 0 0],'same');
        masktmp(cv>0) = 1;
    end
end
masktmp(:,~ind_low_signal) = zeros(size(chm.beta_raw_2,1),sum(~ind_low_signal));
maskMOL = maskMOL | masktmp;

% 3. relax

maskPLOT = maskUC.*maskMOL;
% maskPLOT = maskMOL;

ind_PLOT_top0 = NaN(size(chm.time));
for j=1:length(chm.time)
   ind_last = find(maskPLOT(:,j),1,'last'); 
   if ~isempty(ind_last)
       ind_PLOT_top0(j) = ind_last;
   else
       ind_PLOT_top0(j) = 0;
   end
end
jmax = 2;
ind_PLOT_top = ind_PLOT_top0;
for j=1:length(chm.time)
    neighs = j-jmax:j+jmax;
    neighs = neighs(neighs>=1 & neighs<=length(chm.time));
    restr = ind_PLOT_top0(neighs);
    restr = restr(restr<length(chm.range));
    [~,ind] = max(restr);
    if(~isempty(ind))
        ind_PLOT_top(j) = restr(ind);
    end
end

aerosol_top = NaN(1,length(chm.time));
aerosol_top(ind_PLOT_top>0) = chm.range(ind_PLOT_top(ind_PLOT_top>0));


catch err
  disp([datestr(dn,'yyyymmdd') ' failed...']);  
end

end