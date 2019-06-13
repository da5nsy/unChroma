% Trying to find a filter that reduces chromatic contrast such that a
% normal observer becomes an anomalous colour observer.

% Like 'enChroma' but the opposite.

% This version entirely removed energy at each wavelength interval in turn
% to test the effect on MB chromaticity.

% Then we make a filter out of the relative ability to reduce MB1 and apply
% that to the colour signals, and recalculate MB chromaticities

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

%% Calculate colour signal

CS = SPD.*SRF;

% figure,plot(SToWls(S),SRF)
% figure,plot(SToWls(S),CS)

for i = 1:S(3)
    CSm(:,:,i) = CS; %CS modified
    CSm(i,:,i) = 0;
end

%% Calculate MB chromaticity

load T_CIE_Y10.mat
T_lum = SplineCmf(S_CIE_Y10,T_CIE_Y10,S);

for i=1:S(3)
    LMS(:,:,i) = SSF*CSm(:,:,i);
    MB(:,:,i) = LMSToMacBoyn(LMS(:,:,i),SSF,T_lum);
end

%% Plot MB over range
figure, hold on
for i=1:S(3)
    scatter(MB(1,:,i),MB(2,:,i),'.')
    drawnow
    %pause(0.1)
end

%% Compute standard deviation of set over wavelength

for i=1:S(3)
    sd(i) = std(MB(1,:,i));
end
figure, plot(SToWls(S),sd)

%% Convert sd into a factor to apply to colour signals

sd2 = sd;
sd2(sd2>median(sd2)) = median(sd2);
sd2=sd2-min(sd2);
sd2=sd2/max(sd2);
figure, plot(sd2);

%% Modify colour signals to minimse MB1 variance

CSm2 = CS.*sd2';

figure, plot(CS)
figure, plot(CSm2)

%% Calculate MB for colour signals and modified colour signals

LMS1 = SSF*CS;
LMS2 = SSF*CSm2;

MB_LMS1 = LMSToMacBoyn(LMS1,SSF,T_lum);
MB_LMS2 = LMSToMacBoyn(LMS2,SSF,T_lum);

MB_LMS2(1,:) = MB_LMS2(1,:)+(median(MB_LMS1(1,:))-median(MB_LMS2(1,:))); %normalise per median of both sets

figure, hold on
scatter(MB_LMS1(1,:),MB_LMS1(2,:),'.b')
scatter(MB_LMS2(1,:),MB_LMS2(2,:),'.k')

% %quiver doesn't seem to be working correctly (wrong distances, autoscaling perhaps?)
%quiver(MB_LMS1(1,:),MB_LMS1(2,:),MB_LMS2(1,:)-MB_LMS1(1,:),MB_LMS2(2,:)-MB_LMS1(2,:)) 

% simple lines instead
for i=1:size(MB_LMS1,2)
    plot([MB_LMS1(1,i),MB_LMS2(1,i)],[MB_LMS1(2,i),MB_LMS2(2,i)],'k')
end