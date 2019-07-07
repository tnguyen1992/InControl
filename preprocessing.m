
% PREPROCESSING does the general preprocessing of the fnirs data. The
% function includes the following steps
%   * Conversion from wavelength data to optical density
%   * Removing of bad channels
%   * Wavlet-based motion correction
%   * Pulse quality check
%   * Bandpass filtering
%   * Conversion from optical density to changes in concentration (HbO, HbR and HbT)
%   * Xu Cui's bad channel check
%
% Use as
%   PREPROCESSING( cfg, data )
%
% where the input data has to be the result from CARE_NIRX2NIRS or
% the exported *.nirs output from NIRStar.
%
% The configuration options are
%   cfg.pulseQualityCheck = apply visual pulse quality check, 'yes' or 'no', (default: 'no')
%
% TODO: Fix or remove application of enPruneChannels.
%
% SEE also HMRINTENSITY2OD, ENPRUNECHANNELS, HMRMOTIONCORRECTWAVELET,
% HMRMOTIONARTIFACT, HMRBANDPASSFILT, HMROD2CONC, CARE_XUCHECKDATAQUALITY


% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function data = preprocessing( cfg, data )

% convert the wavelength data to optical density
cfg = [];
cfg.info = 'Wavelength to Optical Density';
data.cfg = cfg;
data.dod = hmrIntensity2OD( data.d );                           

% checking for bad channels and removing them (SD.MeasListAct has zeros 
% input for bad channels)
 cfg = [];
 cfg.info      = 'Removing bad channels by enPruneChannels()';
 cfg.tInc      = ones(size(data.aux,1),1);                                                 
 cfg.dRange    = [0 10000000];
 cfg.SNRthresh = 2;
 cfg.resetFlag = 0;
 cfg.previous  = data.cfg;
 data.cfg      = cfg;
 data.SD.MeasListAct =  ones(size(data.SD.MeasList,1),1); 
 data.SD       = enPruneChannels(data.dod, data.SD, cfg.tInc, cfg.dRange,...
                                 cfg.SNRthresh, cfg.resetFlag);

% correcting for motion artifacts using Wavelet-based motion correction.                                
cfg = [];
cfg.info            = 'Wavelet-based motion artifact correction';
cfg.iQr             = 1.5;
cfg.previous        = data.cfg;
data.cfg            = cfg;
[~, data.dod_corr]  = evalc(...                                             % evalc supresses annoying fprintf output of hmrMotionCorrectWavelet
                'hmrMotionCorrectWavelet(data.dod, data.SD, cfg.iQr);');

% identifies motion artifacts in an input data matrix d. If any active
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact.
cfg = [];
cfg.info            = 'Marking motion artifacts';
cfg.tInc            = ones(size(data.aux,1),1);                                                 
cfg.tMotion         = 0.5;
cfg.tMask           = 1;
cfg.stdevThreshold  = 50;
cfg.ampThreshold    = 5;
cfg.previous        = data.cfg;
data.cfg            = cfg;
data.fs             = 1/(data.t(2)-data.t(1));                              % sampling frequency of the data
data.tIncAuto       = hmrMotionArtifact(data.dod_corr, data.fs, data.SD,...
                                        cfg.tInc, cfg.tMotion,...
                                        cfg.tMask, cfg.stdevThreshold,...
                                        cfg.ampThreshold);

% run pulse quality check
% cfg.pulseQualityCheck = 'yes';

% if strcmp(cfg.pulseQualityCheck, 'yes')
  cfg = [];
  cfg.info      = 'Pulse quality check';
  cfg.previous  = data.cfg;
  data.cfg      = cfg;
  fprintf('Pulse quality check. Please select bad channels, in which pulse is not visible!\n');
  data.badChannelsPulse = pulseQualityCheck(data.dod_corr, data.SD,... % run pulse quality check on all channels 
                                                 data.t);                         
% end

% bandpass filtering
cfg = [];
cfg.info            = 'Bandpass filtering';
cfg.lpf             = 0.5;                                                  % in Hz
cfg.hpf             = 0.01;                                                 % in Hz
cfg.previous        = data.cfg;
data.cfg            = cfg;
data.dod_corr_filt  = hmrBandpassFilt(data.dod_corr, data.fs, cfg.hpf, ...
                                      cfg.lpf);

% convert changes in OD to changes in concentrations (HbO, HbR, and HbT)
cfg = [];
cfg.info      = 'Optical Density to concentrations (HbO, HbR, and HbT)';
cfg.ppf      = [6 6];                                                       % partial pathlength factors for each wavelength.
cfg.previous  = data.cfg;
data.cfg      = cfg;
data.dc       = hmrOD2Conc(data.dod_corr_filt, data.SD, cfg.ppf);

% extract hbo and hbr
data.hbo = squeeze(data.dc(:,1,:));
data.hbr = squeeze(data.dc(:,2,:));


% reject bad channels, set all values to NaN
% if strcmp(cfg.pulseQualityCheck, 'yes')  
  if ~isempty(data.badChannelsPulse)
    fprintf('Reject bad Channels (pulseQualityCheck), set all values to NaN\n');
    data.hbo(:, data.badChannelsPulse) = NaN;
    data.hbr(:, data.badChannelsPulse) = NaN;
  end
% end



data = rmfield(data, 'aux');                                                % remove field aux from data structure

end
