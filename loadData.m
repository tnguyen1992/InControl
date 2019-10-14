function loadData( cfg )
% LOADDATA loads a specific CARE data files
%
% Use as
%   loadData( cfg )
%
% The configuration options are
%   cfg.srcFolder   = source folder (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs/')
%   cfg.filename    = filename (default: 'CARE_p02a_01_raw_nirs')
%
% SEE also LOAD


% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
srcFolder   = getopt(cfg, 'srcFolder', '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\rawData\');
filename    = getopt(cfg, 'filename', '29-2.nirs');

% -------------------------------------------------------------------------
% Load data and assign it to the base workspace
% -------------------------------------------------------------------------
file_path = strcat(srcFolder, filename,  '.nirs');

if ~exist(file_path, 'file')
  file_path = strcat(srcFolder, filename,  '.mat');
end

if exist(file_path, 'file')
  newData = load(file_path, '-mat');
  vars = fieldnames(newData);
  for i = 1:length(vars)
    assignin('base', vars{i}, newData.(vars{i}));
  end
else
  error('File %s does not exist.', file_path);
end

end

