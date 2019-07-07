%INCONTROL Pipeline 1
%Preprocessing, artifact correction, quality check and bandpassfilter 
%%%%%%%%%%%%%%%

srcPath = '/Users/trinhnguyen/Documents/Projects /InControl/rawData/';                        % raw data location
desPath = '/Users/trinhnguyen/Documents/Projects /InControl/procData/';                  % processed data location
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
if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '*.nirs']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart       = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ['%d-2']);
  end
end

%% Conversion
% for i = numOfPart
%   srcFolder   = strcat(srcPath, sprintf([prefix, '_%02d/'], i));
%   srcNirsSub1 = sprintf(['Subject1/', prefix, '_%02d.nirs'], i);
%   srcNirsSub2 = sprintf(['Subject2/', prefix, '_%02d.nirs'], i);
%   fileSub1    = strcat(srcFolder, srcNirsSub1);
%   fileSub2    = strcat(srcFolder, srcNirsSub2);
%   desFolder   = strcat(desPath, 'nirs/'); 
%   
%   if exist(fileSub1, 'file') && exist(fileSub1, 'file')
%     fileDesSub1 = strcat(desFolder, sprintf([prefix, ...
%                         '_d%02da_nirs_'], i), '.nirs');
%     fprintf('<strong>Copying NIRS data for dyad %d, subject 1...</strong>\n', i);
%     copyfile(fileSub1, fileDesSub1);
%     fprintf('Data copied!\n\n');
%     fileDesSub2 = strcat(desFolder, sprintf([prefix, ...
%                         '_d%02db_nirs_'], i), '.nirs');
%     fprintf('<strong>Copying NIRS data for dyad %d, subject 2...</strong>\n', i);
%     copyfile(fileSub2, fileDesSub2);
%     fprintf('Data copied!\n\n');
%   else
%     cfg = [];
%     cfg.dyadNum     = i;
%     cfg.prefix      = prefix;
%     cfg.srcPath     = srcPath;
%     cfg.desPath     = desFolder;
%     cfg.SDfile      = strcat(gsePath, prefix, '.SD');
%     
%     nirs_conv( cfg );
%   end
% end

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

