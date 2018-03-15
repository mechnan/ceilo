function [alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(z,P,T,lambda_rec,lambda_em)
%[alpha_mol,beta_mol,lidar_signal,lidar_signal_r2,density]=get_rayleigh_v3(z,P,T,,lambda_rec,lambda_em)
%Calculate Rayleigh bacsckatter, extinction and attenuated backscatter
% INPUTS
% z: Range (m) (NOT ALTITUDE)
% T: Temperature(k)
% P: Pressure (Pa)
% lambda_rec: Wavelength of reception (nm)
% lambda_em : wavelength of emission. (if empty, consider that emission is the same than reception
%
% Outputs
% alpha_mol : Molecular Extinction (m-1)
% beta_mol: Molecular Backscatter (m-1.sr-1)
% lidar_signal : simulated background corrected Lidar signal molecular layer
% beta_att : Molecular attenuated backscatter (m-1.sr-1)(Or simulated range
% and background corrected Lidar signal molecular layer)
% density : Molecular density
%
% Examples:
% [alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(0:500:1000,[96200 90700 85400],[2286 285 284],355)
% [alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(0:500:1000,[96200 90700 85400],[2286 285 284],355,387)
%
% from (Bucholtz, 1995)
% By M. Hervo Potenza 05/2012
% V3: can have different wavelengths for emission and reception

%% Check Inputs
if nargin==4
    lambda_em=lambda_rec;
    disp(['Calc Molecular (' num2str(lambda_em) 'nm)'])

%     disp('Elastic Signal. Emission is the same than reception')
else
    disp(['Calc Molecular for Inelastic Signal. Emission ' num2str(lambda_em) ' reception ' num2str(lambda_rec) ])
end
if length(z)~=length(P) || length(z)~=length(T)
    error('Check rayleigh input size')
end
if size(z,1)==1
    z=z';
    disp('Rotate z ')
end
if size(P,1)==1
    P=P';
    disp('Rotate P ')
end
if size(T,1)==1
    T=T';
    disp('Rotate T ')
end
if max(P)<15000
    error('P must be in Pa')
end
if max(T)<50
    error('T must be in K')
end
if any(isnan(P)) || any(isnan(T))
    error('Nan in P or T')
end

%% Constants
T0=273.15+15;% K
P0=101325;%Pa
% m=1.0002857;%refractive index
rho=0.0301;%depol factor
N=2.547e25;% Molecular density(m-3)
lambda_rec=lambda_rec*1e-9;% nm in m
lambda_em=lambda_em*1e-9;% nm in m;
%% refractive index
m=(5791817/(238.0185-(1/(lambda_rec*1e6))^2)+167909/(57.362-(1/(lambda_rec*1e6))^2))*1e-8+1;
%% Calc alpha and beta
beta_mol_tot=NaN(size(T));
beta_mol_tot_em=NaN(size(T));
% sigma=24*pi()^3*((m^2-1)^2)*(6+3*rho)/(lambda^4*N^2*(m^2+2)^2*(6-7*rho));
R=8.314418;
Navogadro=6.022005e23;
density=Navogadro*P/R./(T);

% alpha_mol=sigma*density;

for i=1:size(z,1);
    % From Bucholtz 1995
    beta_mol_tot(i)=24*pi()^3*((m^2-1)^2)*(6+3*rho)/...
        (lambda_rec^4*N^2*(m^2+2)^2*(6-7*rho))*N*T0*P(i)/P0/T(i);
    beta_mol_tot_em(i)=24*pi()^3*((m^2-1)^2)*(6+3*rho)/...
        (lambda_em^4*N^2*(m^2+2)^2*(6-7*rho))*N*T0*P(i)/P0/T(i);
    
end
%beta_vol=24*pi()^3*((m^2-1)^2)*(6+3*rho)/...
%   (lambda^4*N^2*(m^2+2)^2*(6-7*rho))*N;

gamma=rho/(2-rho);
Pray=3/4/(1+2*gamma)*(1+3*gamma+(1-gamma)*cos(pi())^2);

beta_mol=beta_mol_tot/4/pi()*Pray;
alpha_mol=beta_mol*8*pi()/3;
beta_mol_em=beta_mol_tot_em/4/pi()*Pray;
alpha_mol_em=beta_mol_em*8*pi()/3;
%% Calc Beta apparant
lidar_signal=NaN(size(P));
beta_att=NaN(size(P));

trans=NaN(size(P));
trans_em=NaN(size(P));
step_z=z(2)-z(1);

for i=1:length(z)
    trans_em(i)=exp(-sum(alpha_mol_em(1:i)*step_z));
    trans(i)=exp(-sum(alpha_mol(1:i)*step_z));
    lidar_signal(i,1)=beta_mol(i)*trans_em(i)*trans(i)/z(i)/z(i);
    beta_att(i,1)=beta_mol(i)*trans_em(i)*trans(i);
end
