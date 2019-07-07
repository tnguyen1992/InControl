%INCONTROL Pipeline 2
%Preprocessing, artifact correction, quality check and bandpassfilter 
%%%%%%%%%%%%%%%

srcPath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\procData\';                        % raw data location
desPath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\procData\';                  % processed data location
% gsePath = '\\fs.univie.ac.at\homedirs\nguyenq22\Documents\Projekte\InControl\procData\gen\';                    % path to CARE.SD


% prefix='CT';                                                              % Name of Project

%% Scan for all subjects
if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '*_preproc.mat']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart       = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ['%d-2']);
  end
end


%%
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % load preprocessed data
  cfg             = [];
  cfg.srcFolder   = strcat(srcPath);
  cfg.filename    = sprintf(['%02d_preproc'], i);
  
  fprintf('Load preprocessed data...\n');
  loadData( cfg );
  
%%

% -------------------------------------------------------------------------
% Basic variables
% -------------------------------------------------------------------------
colBaseline  = 2;
colNeutral     = 3;
colTask       = 1;


colAll            = colTask|colBaseline|colNeutral;

durTask  = round(30 * ...                % duration task condition
                                  data_preproc.fs - 1);
durNeutral     = round(30 * ...                 % duration neutral condition
                                  data_preproc.fs - 1);
durBaseline       = round(30 * ...                  % duration baseline condition
                                  data_preproc.fs - 1);

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
sMatrix = data_preproc.s;

evtTask  = find(sMatrix(:, colTask) > 0);
evtNeutral     = find(sMatrix(:, colNeutral) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);

for j = evtTask'
    sMatrix(j:j+durTask, colTask) = 1; 
end

for j = evtNeutral'
    sMatrix(j:j+durNeutral, colNeutral) = 1;
end

for j = evtBaseline'
    sMatrix(j:j+durBaseline, colBaseline) = 1;
end

% eventMarkers      = data_preproc.eventMarkers(colAll);
sMatrix           = sMatrix(:, 1:3);

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
fprintf('<strong>Conduct generalized linear model regression for all channels...</strong>\n');
data_glm = execGLM(sMatrix, data_preproc);


%% save beta values of glm regression
  cfg             = [];
  cfg.desFolder   = strcat(desPath);
  cfg.filename    = sprintf(['%02d_glm'],i);
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', ...
                     '.mat');

  fprintf('The generalized linear model coefficients of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  saveData(cfg, 'data_glm', data_glm);
  % write csv file
  fprintf('Data stored!\n\n');
  clear data_glm data_preproc 
end

%% GLM Function definition
function data_out = execGLM(s, data_in)
    % build output matrix
    beta = zeros(size(data_in.hbo, 2), 4);                                 
  
  for channel = 1:1:size(data_in.hbo, 2)
    % conduct generalized linear model regression
    % beta estimates for a generalized linear regression of the responses 
    % in data_in.hbo(:, channel) on the predictors in the sMatrix
    if ~isnan(data_in.hbo(1, channel))                                      % check if channel was not rejected during preprocessing
      beta(channel,:) = glmfit(s, data_in.hbo(:, channel));
    else
      beta(channel,:) = NaN;
    end
    
    
  end
  
  % put results into a structure
%   data_out.eventMarkers = evtMark;
  data_out.s            = s;
  data_out.hbo          = data_in.hbo;
  data_out.time         = (1:1:size(data_in.hbo, 1)) / data_in.fs;
  data_out.fsample      = data_in.fs;
  data_out.channel      = 1:1:size(data_in.hbo, 2);
  data_out.beta         = beta(:, 2:end);                                    % for the existing conditions only the columns 2:end are relevant  
fprintf('<strong>Generalized linear model was computed and saved...</strong>\n');


end