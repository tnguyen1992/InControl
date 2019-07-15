%INCONTROL Pipeline 1
%Preprocessing, artifact correction, quality check and bandpassfilter 
%%%%%%%%%%%%%%%

srcPath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\rawData\';                        % raw data location
desPath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\procData\';                  % processed data location
% gsePath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\procData\gen\';                    % path to CARE.SD


% prefix='CT';                                                              % Name of Project

%% Create SD file for NIRx2nirs conversion
% cfg = [];
% cfg.dyad    = [prefix, '_01'];
% cfg.srcPath = srcPath;
% cfg.gsePath = gsePath;
% 
% createSDfile( cfg );

%% Scan for all subjects
  sourceList    = dir([srcPath, '*.oxy4']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart       = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ['%d-2']);
  end


%% Conversion
% a window with missing dongle will pop up, but just ignore the window and
% matlab will do the conversion anyway

for i = numOfPart
  srcFolder   = strcat(srcPath, sprintf(['%02d-2.oxy4'], i));
  srcNirs = sprintf(['%02d-2.nirs'], i);
  fileSub1    = strcat(srcFolder, srcNirs);
  desFolder   = strcat(srcPath, sprintf(['%02d-2'], i)); 
  
[nirs_data, events] = oxysoft2matlab(srcFolder, 'homer', desFolder, [], []);
  
end

%% preprocessing
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % extract event markers
  cfg = [];
  cfg.dyad    = sprintf(['%02d-2'], i);
  cfg.srcPath = srcPath;
  
%   fprintf('Extract event markers from hdr file...\n');
%   eventMarkers = extractEventMarkers( cfg );
  
  % load raw data of subject 1
  cfg             = [];
  cfg.srcFolder   = strcat(srcPath);
  cfg.filename    = sprintf(['%02d-2'], i);
  
  fprintf('Load raw nirs data of subject...\n');
  loadData( cfg );
  
%   if ~isequal(length(eventMarkers), size(s, 2))
%     error('Loaded event markers and raw data of subject 1 doesn''t match!');
%   end
  
  data.SD            = SD;
  data.d             = d;
  data.s             = s;
  data.aux           = aux;
  data.t             = t;
%   data_raw.sub1.eventMarkers  = eventMarkers;
  
  clear SD d s aux t
  
  
  
  % preprocess raw data of both subjects
  cfg = [];
  cfg.pulseQualityCheck = 'yes';

  data_preproc = preprocessing(cfg, data);
  
  % save preprocessed data
  cfg             = [];
  cfg.desFolder   = strcat(desPath);
  cfg.filename    = sprintf(['%02d_preproc'], i);
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  saveData(cfg, 'data_preproc', data_preproc);
  fprintf('Data stored!\n\n');
  clear data_raw
end

