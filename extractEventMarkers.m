function eventMarkers = extractEventMarkers( cfg )
% EXTRACTMARKERS extract the available markers for a dyad from a *.hdr 
% file.
%
% Use as
%   eventMarkers = extractEventMarkers( cfg )
%
% The configurations options are
%   cfg.dyad    = dyad description (i.e. 'CARE_02')
%   cfg.prefix      = CARE or DCARE, defines raw data file prefix (default: CARE)
%   cfg.srcPath = location of NIRx output for both subjects of the dyad
%
% SEE also CARE_NIRX2NIRS

% Copyright (C) 2017, Daniel Matthes, MPI CBS
% adapted by Trinh Nguyen (2019)


% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad        = getopt(cfg, 'dyad', []);
prefix      = getopt(cfg, 'prefix', 'INCONTROL');
srcPath     = getopt(cfg, 'srcPath', []);

if isempty(srcPath)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No file prefix is specified!');
end

% -------------------------------------------------------------------------
% Check if *.hdr-Files are existing
% -------------------------------------------------------------------------
SubSrcDir  = strcat(srcPath, dyad);


if ~exist(SubSrcDir, 'dir')
  error('Directory: %s does not exist', SubSrcDir);
else
  Sub_hdrFile = strcat(SubSrcDir, dyad, '.hdr');
  if ~exist(Sub_hdrFile, 'file')
    error('hdr file: %s does not exist', Sub_hdrFile);
  end
end


% -------------------------------------------------------------------------
% Extract event markers
% -------------------------------------------------------------------------
subString = strsplit(dyad, '_');
subNum = str2double(subString{2});

evtMarker = getEvtMark( Sub_hdrFile, prefix, subNum );

end

% -------------------------------------------------------------------------
% SUBFUNCTION get event markers from *.hdr file
% -------------------------------------------------------------------------
function evtMarker = getEvtMark( hdrFile, pf, num )
fid = fopen(hdrFile);
tmp = textscan(fid,'%s','delimiter','\n');                                  % this just reads every line
hdr_str = tmp{1};
fclose(fid);

keyword = 'Events="#';
ind = find(strncmp(hdr_str, keyword, length(keyword))) + 1;
ind2 = find(strncmp(hdr_str(ind+1:end), '#' , 1)) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
events = events(:,2:3);

evtMarker = unique(events(:,1));

end


