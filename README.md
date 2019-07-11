# InControl Toolbox for Tilburg project

1) Add toolbox and script folder(s) to path (homer2)

The recommended structure of folders: 

Documents/MATLAB/Project/
- rawData
- procData
- scripts
- toolboxes

2) Change srcpath and despath in both Pipeline scripts accordingly to your folder structure
3) First run Pipeline 1 for signal processing, then run Pipeline 2 for GLM 

The processing pipeline includes 
- Conversion to Optical Density
- enPruneChannels
- Wavelet-based motion correction
- Artifact detection by channel
- Pulse Quality Check
- Conversion to HbO, HbR, HbT
