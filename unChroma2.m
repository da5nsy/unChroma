% Second attempt using a more aggressive plan - wipe out everything outside
% of the L-M correlation window and the S cone sensitivity.

clear, clc, close all

%% Load some surfaces
load sur_vrhel.mat

%% Load an illuminant
load spd_D65.mat

%% Load an observer
load T_cones_ss2.mat

%% Match sampling period and interval

SRF = SplineSrf(S_vrhel,sur_vrhel,S_D65);
SPD = spd_D65;
SSF = SplineCmf(S_cones_ss2,T_cones_ss2,S_D65);

S = S_D65;

clearvars -except SRF SPD SSF S

load T_CIE_Y10.mat
T_lum = SplineCmf(S_CIE_Y10,T_CIE_Y10,S);

%% Calculate colour signal

CS = SPD.*SRF;

% figure,plot(SToWls(S),SRF)
% figure,plot(SToWls(S),CS)

%% Compute correlation window

figure, hold on
CS_c = corr(CS');
imagesc(CS_c)
axis image
colormap gray

% Overlay SSF
plot(SSF'*S(3),'--')

% Visual inspection shows window from roughly 30-43, aka 520 - 590nm

%% Define factor to apply to colour signals

fac = ones(S(3),1);

% Block from 20 to 30 (after roughly half peak of s, till LM correlation window starts) 
fac(20:30) = 0;

% Block from 43 onwards (after LM correlation window)
fac(43:end) = 0;

figure, plot(fac)


%% Modify colour signals to minimse MB1 variance

CSm = CS.*fac;

figure, plot(CS)
figure, plot(CSm)

%% Calculate MB for colour signals and modified colour signals

LMS1 = SSF*CS;  %normal
LMS2 = SSF*CSm; %modified

MB_LMS1 = LMSToMacBoyn(LMS1,SSF,T_lum);
MB_LMS2 = LMSToMacBoyn(LMS2,SSF,T_lum);

MB_LMS2(1,:) = MB_LMS2(1,:)+(median(MB_LMS1(1,:))-median(MB_LMS2(1,:))); %normalise per median of both sets

figure, hold on
scatter(MB_LMS1(1,:),MB_LMS1(2,:),'.r','DisplayName','pre')
scatter(MB_LMS2(1,:),MB_LMS2(2,:),'.k','DisplayName','post')

legend('Autoupdate','off')

% %quiver doesn't seem to be working correctly (wrong distances, autoscaling perhaps?)
%quiver(MB_LMS1(1,:),MB_LMS1(2,:),MB_LMS2(1,:)-MB_LMS1(1,:),MB_LMS2(2,:)-MB_LMS1(2,:)) 

% simple lines instead
for i=1:size(MB_LMS1,2)
    plot([MB_LMS1(1,i),MB_LMS2(1,i)],[MB_LMS1(2,i),MB_LMS2(2,i)],'k')
end