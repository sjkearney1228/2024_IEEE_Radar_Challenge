% This script lets you run an FMCW Radar continuously for a certain number
% of steps.
% 
% % Setup:
%
% Connect the Vivaldi antenna to Phaser SMA Out2. Place the Vivaldi antenna
% in the field of view of the Phaser and point it at the Phaser.
%
% Notes:
%
% Run this script to continuously run the FMCW radar for demonstration.
% The first time this script is run, the data collection may not occur
% properly.
%
% Copyright 2023 The MathWorks, Inc.

%% Clear workspace and load calibration weights

clear; close all;

%% First, setup the system, see fmcwDemo.m for more details

instance = 5;

% Carrier frequency
fc = 10e9;
lambda = physconst("LightSpeed")/fc;

% Put some requirements on the system
% maxRange = 10;
maxRange = 30;
% rangeResolution = 1/3;
rangeResolution = 1/6;
% maxSpeed = 5;
maxSpeed = 10;
% speedResolution = 1/2;
speedResolution = 1/6;

% Determine some parameter values
rampbandwidth = ceil(rangeres2bw(rangeResolution)/1e6)*1e6;
fmaxdop = speed2dop(2*maxSpeed,lambda);
prf = 2*fmaxdop;
nPulses = ceil(2*maxSpeed/speedResolution);
tpulse = ceil((1/prf)*1e3)*1e-3;
tsweep = getFMCWSweepTime(tpulse,tpulse);
sweepslope = rampbandwidth / tsweep;
fmaxbeat = sweepslope * range2time(maxRange);
fs = max(ceil(2*fmaxbeat),520834);

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc,fs,tpulse,tsweep,nPulses,rampbandwidth);

% Clear cache
rx();

% Use constant amplitude baseband transmit data
amp = 0.9 * 2^15;
txWaveform = amp*ones(rx.SamplesPerFrame,2);

%% Next, run continuously for nCaptures

nCaptures = 100;
inst = num2str(instance);

% Create a range doppler plot
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
    SweepSlope=sweepslope,PRFSource="Property",PRF=prf);
ax = axes(figure);
for i = 1:nCaptures
    % capture data
    data{i} = captureTransmitWaveform(txWaveform,rx,tx,bf);

    % Arrange data into pulses
    data_arranged{i} = arrangePulseData(data{i},rx,bf,bf_TDD);

    % Plot the data
    rd.plotResponse(data_arranged{i});
    xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);
    drawnow;
    saveas(gcf,['C:\Users\ci4ru\OneDrive\Desktop\Sean Darta\Sean_03_30\quad_md\range_doppler\sample_' inst '\' num2str(i) '.png']);

end

% save(['C:\Users\ci4ru\OneDrive\Desktop\Sean Darta\Sean_03_28\test' inst '.mat'],"data");
save(['C:\Users\ci4ru\OneDrive\Desktop\Sean Darta\Sean_03_30\quad_md\sample' inst '_arrange.mat'],"data_arranged");

% Disable TDD Trigger so we can operate in Receive only mode
disableTddTrigger(bf_TDD)

close all;