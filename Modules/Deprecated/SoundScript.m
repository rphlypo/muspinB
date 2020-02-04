%% Sound Script
% by Kevin Parisot
% created on 10/01/2018
% last edited on 10/01/2018


freq = 48000; nrchannels = 2; beep_dur = .03;
    [beep, samplingRate] = MakeBeep(500, beep_dur, freq);
    Snd('Open');
    
    % Perform basic initialization of the sound driver:
    InitializePsychSound;
    
    % Open the default audio device [], with default mode [] (==Only playback),
    % and a required latencyclass of zero 0 == no low-latency mode, as well as
    % a frequency of freq and nrchannels sound channels.
    % This returns a handle to the audio device:
    try
        % Try with the 'freq'uency we wanted:
        %         pahandle = PsychPortAudio('Open');
        pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
    catch
        % Failed. Retry with default frequency as suggested by device:
        fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
        fprintf('Sound may sound a bit out of tune, ...\n\n');
        
        psychlasterror('reset');
        %         pahandle = PsychPortAudio('Open');
        pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
    end
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, [beep; beep]);