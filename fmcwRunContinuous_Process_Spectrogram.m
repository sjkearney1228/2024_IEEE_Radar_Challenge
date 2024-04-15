%% Clear workspace
clc; clear; close all;

DATA_DIR = 'E:\Radar_Challenge2024\Sean Darta\Sean_03_30\test_data\';

pattern = strcat(DATA_DIR, '*5*arrange.mat');
files = dir(pattern);

I_MAX = numel(files); % # of files in "files"

for i =1: I_MAX  % for the first 20 iteration
        tic
        msg = strcat(['Processing file ', int2str(i), ' of ', int2str(I_MAX)]);   % loading message
        disp(msg);

        fName = files(i).name;
        [foo1, name, foo2] = fileparts(fName);
        fIn = fullfile(files(i).folder, files(i).name);

        % Load in data
        % load('E:\Radar_Challenge2024\Sean Darta\Sean_03_30\test_data\test5_arrange.mat');
        load(fIn);
        
        % %%% for DATA 03/30
        % maxRange = 30;
        % rangeResolution = 1/6;
        % maxSpeed = 10;
        % speedResolution = 1/6;
        
        % Rearrange data_arranged into 534x(20x100) matrix
        % Rearrange data_arranged into 267x(80x100) matrix
        % Rearrange data_arranged into 361x(120x100) matrix
        a = data_arranged{1}; len = length(a(1,:));
        for i =1:length(data_arranged)
            % RDC(:,(i-1)*20+1:i*20) = data_arranged{i};
            RDC(:,(i-1)*len+1:i*len) = data_arranged{i};
        end
        rngpro = fft(RDC(:,:));
        
            
        %% STFT
        % rBin = 1:256;

        % for sample 2 of small quad: 5 to 10m
        % rBin = 1:length(RDC(:,1));
        lenRDC = length(RDC(:,1));
        rBin = round(lenRDC/30)*1:round(lenRDC/30)*10;
        % nfft = 2^10;window = 256;noverlap = 250;shift = window - noverlap;
        nfft = 2^10;window = length(rBin);noverlap = window-20;shift = window - noverlap;
        sx = myspecgramnew(sum(squeeze(rngpro(rBin,:))),window,nfft,shift);
        
        %% cfar bins
        sx2 = abs(flipud(fftshift(sx,1)));
        
        %% Spectrogram
        figure('visible','on');
        colormap(jet(256));
        fig=imagesc([],[],20*log10(sx2./max(sx2(:))));
        
        xlabel('Time (sec)');
        ylabel('Frequency (Hz)');
        caxis([-40 0]) % 40, 50 step time
        % caxis([-20 0]) % 40, 50 step time
        set(gca, 'YDir','normal')
        set(gca,'xtick',[],'ytick',[])
        frame = frame2im(getframe(gca));
        fOut = strcat('E:\Radar_Challenge2024\Sean Darta\Sean_03_30\test_data\spectrogram\',fName(1:end-12),'_1to10m_spectrogram.png');
        % imwrite(frame,['E:\Radar_Challenge2024\Sean Darta\Sean_03_30\test_data\spectrogram\test5_spectrogram.png']);
        imwrite(frame,fOut);
        
        close all
end