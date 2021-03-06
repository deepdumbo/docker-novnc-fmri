function outputData=roianalysis_timecourse(dataPath,dataFileSpec,typeSpec,zoom,roiPath,roiFileSpec,...
  studies,bins,gyri,sides,slices,outputExcelFileName, ...
  preStimMeanSpecifier,tPoints,ranges,decDigits, ...
  userStatFuncs,userHeaders,subBaselineForPerChange)
%ROIANALYSIS_TIMECOURSE Calculates statistics within several ROIs across a time series of images.
%
%  This MATLAB function calculates statistics within numerous ROIs
%  spannning studies, bins, gyri, sides, slices and, optionally, masked
%  ranges and bins.  The script calculates the ROI mean, baseline mean and
%  the percent signal change for each ROI.  The baseline mean can be
%  calculated from specified time points or image files.  The percent
%  signal change can be calculated with or without subtracting the baseline
%  mean.  The output is formatted for a pivot table with all appropriate
%  labels included.  Each study is put on a separate sheet in an Excel
%  file saved at the specified location.
%
%  out=roianalysis_timecourse(dataPath,dataFileSpec,typeSpec,zoom,roiPath,roiFileSpec,...
%    studies,bins,gyri,sides,slices,outputExcelFileName, ...
%    preStimMeanSpecifier,tPoints,ranges,decDigits, ...
%    userStatFuncs,userHeaders,subBaselineForPerChange);
%
%  Inputs:
%    ------ MR Image Data Specificiations ------
%    dataPath is the path to the data to analyze without the series specifier
%    dataFileSpec is a string that is evaluated to generate the file name of the image files to be processed
%    typeSpec is a string or cell array containing the READMR typespec
%    zoom specifies how to zoom in on the images before applying stats.
%      The format is [xo yo xs ys], where (xo,yo) is the new upper left corner,
%      and [xs ys] is the new dimensions of the zoomed images.
%      You may use [] to specify the full image size.
%
%    ------ ROI Specifications ------
%    roiPath is a string specifying the path to the ROI files
%    roiFileSpec is a string that is evaluated to generate the file name of the roi files to be processed
%
%    ------ Subjects and Regions to Analyze ------
%    studies is a cell array of the full study numbers (Study date and exam number)
%    bins is a cell array of bins to analyze.  Just put {'1'} if you don't use 'bin' in the dataFileSpec
%      Note that you must include any leading zeros because this is a string.
%    gyri is a cell array of the names of the gyri to analyze.
%    sides is a cell array of the sides to analyze.
%    slices is a cell array or numeric array of the slices to analyze.
%      If a numeric array is specified, it is automatically converted to a
%      two digit padded integer (i.e. %02d) string.
%
%    ------ Other Variables ------
%    outputExcelFileName is the file name for the output excel file.
%      Saved in dataPath if outputExcelFileName does not include a path.
%    preStimMeanSpecifier determines how the prestimulus baseline is calculated.
%      If preStimMeanSpecifier is a string, (i.e. tstatprofie analysis results)
%        This string is evaluated to generate the file name of the image
%        file containing the baseline values.  The baseline is then calculate
%        calculated as the ROI average within the specified image.  There
%        can be but does not have to be, a different file for each bin and
%        study. 
%      If preStimMeanSpecifier is a vector of indicies, (i.e. mrtest analysis results)
%        The ROI average of across the prestimulus time points
%        tPoints(preStimMeanSpecifier) are used as the prestimulus
%        baseline.  A new baseline is calculated for each ROI, bin, and study.   
%    subBaselineForPerChange determines if baseline is subtracted from data
%      when calculating percent signal change. (==0 don't subtract, ~=0 subtract)
%        Default = 1 if preStimMeanSpecifier is numbers. (i.e. mrtest analysis results)
%        Default = 0 if preStimMeanSpecifier is a string. (i.e. tstatprofie analysis results)
%      NOTE: The data MUST already have the baseline removed for the percent
%        signal change output to be correct if you use subBaselineForPerChange==0
%    tPoints is a vector of labels for each time point
%    ranges is a cell array of 2-element vectors specifying [min,max] ranges, if you are analyzing
%      masked ROIs like those generated by roiCountScript. (Default = {})
%    decDigits is how many digits after the decimal point to show in the range labels.
%      The range labels are also used to generate the masked ROI file names.
%      Note: range values will be rounded if they have more than decDigits after the decimal point.
%      (Default = 2, use [] for default)
%
%    ------ Additional Statistical Functions ------
%    userStatFuncs is a cell array of additional functions that will be passed to ROIStats.
%      Use {} for none.  Default = {}.
%    userHeaders is a cell array of corresponding headers to use in the Excel output.
%      Use {} for none.  Default = {}.
%
%  Outputs:
%    Excel spreadsheet saved within the outputExcelFileName 
%      (in dataPath if outputExcelFileName does not include a path)
%
%    out is an array of structures containing the data sent to the Excel
%      spreadsheet.  The argument is optional and redundant with the output
%      Excel spreadsheet.  The fields are: 
%        out.sheetname: name of sheet data sent to in Excel
%        out.data: cell array of data sent to Excel
%
%  The following code is used to generate the file names:
%  (Note that preStimMeanDataSpec is only calculated if the
%   preStimMeanSpecifier is a string)
%
%    dataSpec = fullfile(dataPath,eval(dataFileSpec));
%    roiSpec = fullfile(roiPath,eval(roiFileSpec));
%    preStimMeanDataSpec = fullfile(dataPath,eval(preStimMeanSpecifier));
%
%  Please note that the following variables are available for use in
%    roiFileSpec, dataFileSpec, and preStimMeanSpecifier:
%    (all variables are cell arrays of strings)
%
%    studies{study} => The current study from studies being analyzed
%    bins{bin}      => The current bin from bins being analyzed
%
%  The following additional variables are avaialable only for use in
%    roiFileSpec:   (all variables are cell arrays of strings)
%
%    gyri{gyrus}    => The current gyrus from gyri being analyzed
%    sides{side}    => The current side from sides being analyzed
%    slices{slice}  => The current slice from slices being analyzed
%
%    % Using "Raw" format typeSpec:
%    dataPath = '\\Server\Share\Group\Experiment.01\Analysis\';
%    dataFileSpec = 'sprintf(''%s\\Avg_%s_V*.img'',studies{study},bins{bin})';
%    typeSpec = {'Float',[64,64,20]};
%
%    % Using "BXH" format typeSpec:
%    dataPath = '\\Server\Share\Group\Experiment.01\Analysis\';
%    dataFileSpec = 'sprintf(''%s\\Avg_%s_V.bxh'',studies{study},bins{bin})';
%    typeSpec = 'BXH';
%
%    zoom = [];
%    roiPath = '\\Server\Share\Group\Experiment.01\Analysis\ROIs\IndividualSlice\';
%    roiFileSpec = 'sprintf(''%s\\%s%s_%s_s%s.roi'',studies{study},gyri{gyrus},sides{side},studies{study},slices{slice})';
%    studies = {'20010101_11111' '20010102_11112' '20010103_11113' '20010104_11114'};
%    bins = {'Category1','Category2','Category3','Category4'};
%    gyri = {'ACG','STS',MFG'};
%    sides = {'r' 'l'};
%    slices = [5:11];
%    outputExcelFileName = 'ROIAnalysisOutput.xls';
%    tPoints = [-3.0:1.5:16.5];
%
%    % For tstatprofile analysis results:
%    preStimMeanSpecifier = 'sprintf(''%s\\baselineAvg.img'',studies{study})'; % "Raw" format
%    preStimMeanSpecifier = 'sprintf(''%s\\baselineAvg.bxh'',studies{study})'; % "BXH" format
%    OR 
%    % For mrtest analysis results:
%    preStimMeanSpecifier = [1:3];
%
%    roianalysis_timecourse(dataPath,dataFileSpec,typeSpec,zoom,roiPath,roiFileSpec,...
%      studies,bins,gyri,sides,slices,outputExcelFileName, ...
%      preStimMeanSpecifier,tPoints);
%
%   Note:  ONLY works if time series are the same length for all studies.
%
%  See Also: ROISTATS, ROIANALYSIS_COUNT, ROIANALYSIS_PEAK, ROIUNIONEXAMS

% Backwards compatibilty note:
% Also supports old-style "Volume" and "Float" formats for backward compatibility.
%   typeSpec = {xSz,ySz,zSz,'volume'} => {'Volume',[xSz,ySz,zSz]}
%   typeSpec = {xSz,ySz,zSz,'float'}  => {'Float' ,[xSz,ySz,zSz]}

% CVS ID and authorship of this code
% CVSId = '$Id: roianalysis_timecourse.m,v 1.23 2005/02/03 16:58:43 michelich Exp $';
% CVSRevision = '$Revision: 1.23 $';
% CVSDate = '$Date: 2005/02/03 16:58:43 $';
% CVSRCSFile = '$RCSfile: roianalysis_timecourse.m,v $';

lasterr('');  % Clear last error message
emsg='';      % Error message string
try           % Use try block to handle deleting the progress bars if an error occurs
  % Check number of inputs
  error(nargchk(14,19,nargin))
  
  % Set defaults
  if nargin < 15, ranges = {}; end
  if nargin < 16 | isempty(decDigits), decDigits = 2; end
  if nargin < 17, userStatFuncs = {}; end
  if nargin < 18, userHeaders = {}; end
  if nargin < 19 | isempty(subBaselineForPerChange)
    if isnumeric(preStimMeanSpecifier) 
      % Default to subtract baseline, if using vector of time points to
      % calculate prestimulus baseline.
      subBaselineForPerChange=1;
    elseif ischar(preStimMeanSpecifier)
      % Default to NOT subtract baseline, if using a separate file to
      % calculate prestimulus baseline.
      subBaselineForPerChange=0;
    else
      emsg = 'preStimMeanSpecifier must be a single string or a vector of indicies!'; error(emsg);
    end
  end
  
  % Check input variables
  if ~ischar(dataPath)
    emsg = 'dataPath must be a single string.'; error(emsg);
  end
  if ~ischar(dataFileSpec)
    emsg = 'dataFileSpec must be a single string.'; error(emsg);
  end
  % Support old-style readmr parameters.
  if iscell(typeSpec) & length(typeSpec)==4 & any(strcmpi(typeSpec{4},{'Volume','Float'})) & ...
      isnumeric(typeSpec{1}) & isnumeric(typeSpec{2}) & isnumeric(typeSpec{3})
    typeSpec={typeSpec{4},[typeSpec{1:3}]};
  end
  if ~isempty(zoom) & (length(zoom)~=4 | any(~isnumeric(zoom)))
    emsg = 'Invalid zoom parameters.'; error(emsg);
  end
  if ~ischar(roiPath) 
    emsg = 'roiPath must be a single string.'; error(emsg);
  end
  if ~ischar(roiFileSpec)
    emsg = 'roiFileSpec must be a single string.'; error(emsg);
  end
  if ~iscellstr(studies) | ~iscellstr(gyri) | ~iscellstr(sides) | ~iscellstr(bins)
    emsg = 'studies, gyri, bins, and sides must all be cell arrays of strings.'; error(emsg)
  end
  if any(~isnumeric(tPoints))
    emsg = 'tPoints must be a numeric array.'; error(emsg)
  end
  if ~(isnumeric(slices) | iscellstr(slices))
    emsg = 'slices must be a cell array of strings or a vector of numbers.'; error(emsg);
  end
  
  if ~isempty(ranges)
    if ~iscell(ranges)
      emsg = 'ranges must be a cell array.'; error(emsg);
    end
    if any(~cellfun('isclass',ranges,'double') | ~cellfun('isreal',ranges) | ...
        cellfun('prodofsize',ranges) ~= 2)
      emsg = 'Each element in ranges must be a 2-element numeric vector.'; error(emsg);
    end
    if length(decDigits)~=1 | ~isint(decDigits)
      emsg = 'decDigits must be an integer.'; error(emsg);
    end
  end
  
  if ~(ischar(preStimMeanSpecifier) | isnumeric(preStimMeanSpecifier))
    emsg = 'preStimMeanSpecifier must be a single string or a vector of indicies!'; error(emsg);
  end
  if ~isnumeric(subBaselineForPerChange) | (length(subBaselineForPerChange)~=1)
    emsg = 'subBaselineForPerChange must be a single number!'; error(emsg);
  end
  
  if ~ischar(outputExcelFileName)
    emsg = 'outputExcelFileName must be a single string.'; error(emsg);
  end
  
  if ~iscellstr(userStatFuncs) | ~iscellstr(userHeaders)
    emsg = 'userStatFuncs and userHeaders must both be cell arrays of strings.'; error(emsg)
  end
  
  if length(userStatFuncs) ~= length(userHeaders)
    emsg = 'There must be a user header for each user stat function!'; error(emsg);
  end
  
  % Convert slices to a cell array (Padding using %02d)
  if isnumeric(slices)
    slicesOrig=slices;
    slices=cell(size(slicesOrig));
    for n=1:length(slicesOrig)
      slices{n}=sprintf('%02d',slicesOrig(n));
    end
    clear('slicesOrig'); 
  end
  
  % Determine output data array size and check to see if it is too long for Excel
  nBins = length(bins);
  nGyri = length(gyri);
  nSides = length(sides);
  nSlices = length(slices);
  tSz = length(tPoints);
  if isempty(ranges)
    nMaskBins = 1;
    nMaskBinUnions = 0;
    nRanges = 1;
  else
    nMaskBins = nBins;
    nMaskBinUnions = 1;      % For unions of masked bins
    nRanges = length(ranges);
  end
  len = 1+nBins*nGyri*nSides*nSlices*tSz*nRanges;
  if len > 65536
    emsg = 'You are trying to analyze too many ROIs/tPoints/ranges! Excel is limited to 65536 rows.';
    error(emsg);
  end
    
  % Build list of colHeaders and statFuncs
  % Note: Code farther below assumes the following order based on the column anchors
  ROIHeaders = {'Study' 'Bin' 'Gyrus' 'Side' 'Slice'};
  rangeHeaders = {'Mask Bin' 'Mask Range'};
  timeHeaders = {'Time Point'};
  meanHeaders = {'Mean' 'PreStimMean' '% Signal Change'};
  if isempty(ranges)
    colHeaders = [ROIHeaders timeHeaders meanHeaders];
  else
    colHeaders = [ROIHeaders rangeHeaders timeHeaders meanHeaders];
  end
  studyCol = strmatch('Study',colHeaders,'exact');      % Anchors ROI label info
  maskCol = strmatch('Mask Bin',colHeaders,'exact');    % Anchors mask labels
  timeCol = strmatch('Time Point',colHeaders,'exact');  % Anchors time point label
  meanCol = strmatch('Mean',colHeaders,'exact');        % Anchors mean calcs
  userCol = length(colHeaders)+1;                       % Anchors start of user-specified statFuncs, if any
  colHeaders = [colHeaders userHeaders(:)'];            % Add user's headers
  
  if ~isempty(ranges)
    % Build list of range labels
    % Ranges labels are handled specially: they are put in rows under the "Range" column
    for n = 1:nRanges
      range = ranges{n};
      rangeLabels{n} = sprintf('%.*f to %.*f',decDigits,range(1),decDigits,range(2));
    end
  end
  
  % Build complete list of statFuncs
  %  meanStatFuncs = {'Mean'};
  meanStatFuncs = {'evalif(''isempty(voxels)'',''NaN'',''mean(voxels)'')'};  % Don't trigger divide by zero warning
  statFuncs = [meanStatFuncs userStatFuncs(:)'];
   
  % Initalize prototype output data array (All output for a single study)
  dataProto = cell(len,length(colHeaders));
  dataProto(1,:) = colHeaders;
  
  clear groupedRoi        % In case it exists in the current workspace
  roibaseSize = [0 0 0];  % Set to a null value in case it exists in the current workspace
  data_i = 2;             % Index to output data array (points to current empty row)
  
  % Initialize progress bar for count number of tsv's to process
  nTsv = length(studies)*length(bins);
  tsv_i = 1;  
  p = progbar(sprintf('Loading ROIs for 0 of %d TSVs',nTsv),[-1 0.6 -1 -1]);
  
  % Check to make sure that all ROIs exist, their baseSizes are correct,
  % and generate all of the labels for a prototype output data array
  for study = 1:length(studies)
    for bin = 1:nBins
      % Update Progress bar for number of ROIs processed if it still exists
      if ~ishandle(p), emsg = 'User abort'; error(emsg); end
      progbar(p,tsv_i/nTsv,sprintf('Loading ROIs for %d of %d TSVs',tsv_i,nTsv));
      
      groupedRoi_i = 1;     % Initialize counter for the current roi in a group
      tsv_i = tsv_i+1;      % Update TSV counter
         
      for gyrus = 1:nGyri
        for side = 1:nSides
          for slice = 1:nSlices
            for n = 1:nRanges
              allMaskBinsRoi=[];      % Will contain union of all bins for this range
              for maskBin = 1:nMaskBins+nMaskBinUnions
                if maskBin<=nMaskBins
                  % Load and verify the ROI
                  roiSpec = fullfile(roiPath,evalRoiFileSpec(roiFileSpec, ...
                    studies,study,bins,bin,gyri,gyrus,sides,side,slices,slice));
                  if ~isempty(ranges)
                    [pth name ext]=fileparts(roiSpec);
                    rangeStr=strrep(rangeLabels{n},' to ','_');    % Replace ' to ' with '_'
                    binStr=sprintf('b%s',bins{maskBin});
                    roiSpec=fullfile(pth,[name '_' binStr '_' rangeStr ext]);
                  end
                  if ~exist(roiSpec)
                    emsg=['ROI file "' roiSpec '" does not exist!']; error(emsg);
                  else
                    clear roi
                    try
                      load(roiSpec,'-mat');
                    catch
                      emsg=sprintf('Error loading ROI file "%s":\n%s',roiSpec,lasterr); error(emsg);
                    end
                    if ~exist('roi','var') | ~isroi(roi)
                      emsg=['The ROI in "' roiSpec '" is invalid!']; error(emsg);
                    end
                    % Remove .val and .color fields so that all ROIs have the same structure.
                    [tmp1,tmp2,form]=isroi(roi); clear tmp1 tmp2
                    if form == 2, roi = rmfield(roi,{'val','color'}); end, clear form
                    if data_i == 2
                      roibaseSize = roi.baseSize;
                    elseif ~isequal(roi.baseSize,roibaseSize)
                      emsg=['roibaseSize specified does not match the baseSize of ',roiSpec]; error(emsg);
                    end
                  end
                  % Make a union of all masked bins
                  allMaskBinsRoi=roiunion(allMaskBinsRoi,roi);
                else
                  % Use the union of all masked bins
                  roi=allMaskBinsRoi;
                end
                
                groupedRoi(groupedRoi_i,bin,study) = roi;   % Store roi grouping by bin and study
                groupedRoi_i = groupedRoi_i + 1;            % Update pointer to current roi in group
                
                % The prototype is only for one study so only generate it on the first study loop
                if study == 1
                  % Generate vector of indicies in dataProto that the current roi corresponds to
                  curr_i = data_i + [0:tSz-1];
                  
                  dataProto(curr_i,studyCol+1) = repmat(bins(bin),[tSz 1]);                 % Label Bin
                  dataProto(curr_i,studyCol+2) = repmat(gyri(gyrus),[tSz 1]);               % Label Gyrus
                  dataProto(curr_i,studyCol+3) = repmat(sides(side),[tSz 1]);               % Label Side
                  dataProto(curr_i,studyCol+4) = repmat(slices(slice),[tSz 1]);             % Label Slice
                  if ~isempty(ranges)
                    if maskBin<=nMaskBins
                      binLabel=bins{maskBin};
                    else
                      binLabel='All';
                    end
                    dataProto(curr_i,maskCol) = repmat({binLabel},[tSz 1]);                 % Label Mask Bin
                    dataProto(curr_i,maskCol+1) = repmat(rangeLabels(n),[tSz 1]);           % Label Mask Range
                  end
                  dataProto(curr_i,timeCol) = num2cell(tPoints);                            % Label Time Points
                  
                  % Update pointer to open data row and current roi in group
                  data_i = curr_i(end)+1;
                end
                
              end % for maskBin
            end % for n
          end % for slice
        end % for side
      end % for gyrus
    end % for bin
  end % for study
  delete(p) % delete progress bar
  
  % Determine the number of ROIs for each tsv
  nRoi = size(groupedRoi,1);
  % Initialize progress bar for count number of tsv's to process
  p=progbar(sprintf('Processing %d ROI''s for 0 of %d tsv''s',nRoi,nTsv),[-1 0.6 -1 -1]);
  % Initialize counter for tsv progress bar
  tsv_i = 1;
  
  % Initialize output array if requested.
  if nargout > 0,
    outputData=repmat(struct('sheetname',[],'data',[]),1,length(studies)); 
  end
  
  hXL=toexcel('Private');     % Private handle to Excel (invisible until we dump data into it)
  
  % Loop through each study
  for study = 1:length(studies)
    % Make a copy of the prototype output data format
    data = dataProto;
    
    % Initialize index to output data array (points to current empty row)
    data_i = 2;
    
    % Loop through each bin
    for bin = 1:length(bins)
      % Update Progress bar for number of ROIs processed if it still exists
      if ~ishandle(p), emsg='User abort'; error(emsg); end
      progbar(p,tsv_i/nTsv,sprintf('Processing %d ROI''s for %d of %d tsv''s',nRoi,tsv_i,nTsv));
      
      tsv_i = tsv_i+1;  % Update counter
      
      % Determine the file specifier for the data for the study and bin
      dataSpec = fullfile(dataPath,evalDataFileSpec(dataFileSpec,studies,study,bins,bin));
      
      % Calculate statistics for all roi's for this study and bin
      % currdata is a 3D array with dimensions (tPoints, statFuncs, roi)
      currdata = roistats(dataSpec,typeSpec,zoom,groupedRoi(:,bin,study),statFuncs);
      
      % Check to make sure that the output statistics has the number of time points expected
      if size(currdata,1) ~= tSz
        emsg=['Study ', dataSpec , ' does not contain ' , num2str(tSz) , ' time points!']; error(emsg);
      end   
      
      % Mean is the first statFunc
      % Move middle singleton dimension to end so we get a 2D matrix
      % Now there is one roi per column of meandata
      meandata = permute(currdata(:,1,:),[1 3 2]);
      
      % --- Calculate prestimulus baseline ---
      if ischar(preStimMeanSpecifier)
        % preStimMeanSpecifier is a string, use it to generate the filename
        % of the image file containing the baseline values.
        
        % Calculate the prestim mean from the volume passed
        % prestimmeanData is a 3D array with dimensions (1, 1, roi)
        % Calculate ONLY the mean (use NaN if there are no voxels)
        preStimMeanDataSpec = fullfile(dataPath, ...
          evalPreStimMeanSpecifier(preStimMeanSpecifier,studies,study,bins,bin));
        
        prestimmean = roistats(preStimMeanDataSpec,typeSpec,zoom,groupedRoi(:,bin,study), ...
          {'evalif(''isempty(voxels)'',''NaN'',''mean(voxels)'')'});
        
        % Check to make sure that the prestimmean output only has one time point
        if size(prestimmean,1) ~= 1
          emsg=['Study ', preStimMeanDataSpec , ' contains more than one time point!']; error(emsg);
        end
        
        % Check to make sure that there is ONLY one statistical function output (mean)
        if size(prestimmean,2) ~= 1
          emsg=['Study ', preStimMeanDataSpec , ' contains more than one statistical function!']; error(emsg);
        end
      
        % Mean is the first statFunc
        % Move middle singleton dimension to end so we get a 2D matrix
        % Now there is one roi per column of meandata
        prestimmean = permute(prestimmean(:,1,:),[1 3 2]);
      else
        % If preStimMeanSpecifier is a vector of numbers, use it as
        % indicies of baseline time points.

        prestimmean = mean(meandata(preStimMeanSpecifier,:),1);
      end
      % Replicate to the number of time points.
      prestimmean = repmat(prestimmean,[tSz 1]);
      
      % --- Calculate the percent signal change for each roi ---
      if subBaselineForPerChange
        % Substract prestimulus baseline
        % NOTE: This method of calculating percent signal change assumes
        %   that the baseline HAS NOT already been removed from the data!
        percentSigChange = meandata./prestimmean - 1;
      else
        % Don't subtract prestimulus baseline
        % NOTE: This method of calculating percent signal change assumes
        %   that the baseline HAS already been removed from the data!     
        percentSigChange = meandata./prestimmean;
      end
      
      % Add current data to the end of the data
      % Note: Using : fills by column left to right, so the data matrix is filled by roi
      data(data_i:data_i+nRoi*tSz-1,studyCol) = studies(study);                    % Label Study
      data(data_i:data_i+nRoi*tSz-1,meanCol) = num2cell(meandata(:));              % Mean
      data(data_i:data_i+nRoi*tSz-1,meanCol+1) = num2cell(prestimmean(:));         % Prestimulus mean
      data(data_i:data_i+nRoi*tSz-1,meanCol+2) = num2cell(percentSigChange(:));    % % Signal Change
      
      % Add user statFuncs
      for u = 1:length(userStatFuncs)
        % Move middle singleton dimension to end so we get a 2D matrix
        % Now there is one roi per column of userdata
        userdata = permute(currdata(:,u+1,:),[1 3 2]);
        data(data_i:data_i+nRoi*tSz-1,userCol+u-1) = num2cell(userdata(:));        % User statFuncs
      end
      
      % Update pointer to open data row
      data_i = data_i+size(groupedRoi,1)*tSz;
    end % for bin
    
    % Send the current subject's data to a new sheet in excel Name Patient Date & Exam #
    toexcel(hXL,data,1,1,studies{study})
    if nargout > 0
      % Save output in matrix
      outputData(study).sheetname=studies{study};
      outputData(study).data=data;
    end
    clear data
  end % for study
  delete(p)	% Delete the progress bar
  
  % Save the workbook and clean up when done analyzing
  if isempty(fileparts(outputExcelFileName))
    % Save in dataPath if outputExcelFileName does not include a path
    outputExcelFileName=fullfile(dataPath,outputExcelFileName);
  end
  toexcel(hXL,'SaveAs',outputExcelFileName);
  toexcel(hXL,'Cleanup');
  
catch                   % Display captured errors and delete progress bar(s) if they exists
  if isempty(emsg)
    if isempty(lasterr)
      emsg='An unidentified error occurred!';
    else
      emsg=lasterr;
    end
  end
  
  if exist('p'), 
    if ishandle(p), delete(p); end
  end
  
  if exist('hXL') & isa(hXL,'activex')
    toexcel(hXL,'ForceDone');
  end
  
  error(emsg);
end

% --- Local functions ---
function dataFileSpecCurr = evalDataFileSpec(dataFileSpec,studies,study,bins,bin)
%evalDataFileSpec - Generate data specifier in a "controlled" environment
%
%  Generate data specifier limiting user to using the variables:
%    studies, study, bins, bin.
try
  dataFileSpecCurr = eval(dataFileSpec);
catch
  error(sprintf(...
    ['Unable to evaluate dataFileSpec!\n', ...
      'Check that it only uses the variables studies{study} and bins{bin}\n', ...
      'Error Message was: %s'],lasterr));
end

function roiFileSpecCurr = evalRoiFileSpec(roiFileSpec,studies,study,bins,bin,gyri,gyrus,sides,side,slices,slice)
%evalRoiFileSpec - Generate ROI specifier in a "controlled" environment
%
%  Generate ROI specifier limiting user to using the variables:
%    studies, study, bins, bin, gyri, gyrus, sides, side, slices, slice
try
  roiFileSpecCurr = eval(roiFileSpec);
catch
  error(sprintf(...
    ['Unable to evaluate roiFileSpec!\n', ...
      'Check that it only uses the variables studies{study}, bins{bin}, gyrus{gyri}, sides{side}, and slices{slice}\n', ...
      'Error Message was: %s'],lasterr));
end

function preStimMeanSpecifierCurr = evalPreStimMeanSpecifier(preStimMeanSpecifier,studies,study,bins,bin)
%evalPreStimMeanSpecifier - Generate data specifier in a "controlled" environment
%
%  Generate data specifier limiting user to using the variables:
%    studies, study, bins, bin.
try
  preStimMeanSpecifierCurr = eval(preStimMeanSpecifier);
catch
  error(sprintf(...
    ['Unable to evaluate preStimMeanSpecifier!\n', ...
      'Check that it only uses the variables studies{study} and bins{bin}\n', ...
      'Error Message was: %s'],lasterr));
end

% Modification History:
%
% $Log: roianalysis_timecourse.m,v $
% Revision 1.23  2005/02/03 16:58:43  michelich
% Changes based on M-lint:
% Make unused CVS variables comments for increased efficiency.
% Remove unnecessary semicolon after function declarations.
% Remove unnecessary commas after try, catch, and else statements.
%
% Revision 1.22  2004/12/14 01:58:00  michelich
% Fixed capitalization of roiunion.
%
% Revision 1.21  2003/12/15 20:04:19  michelich
% Corrected capitalization of isroi.
% Remove val and color fields so that both ROI structure types can be stored
%   in the same array.
%
% Revision 1.20  2003/12/09 23:57:12  michelich
% Minor comment fix.
%
% Revision 1.19  2003/12/09 23:31:24  michelich
% Missing semicolon.
%
% Revision 1.18  2003/12/09 23:26:36  michelich
% Corrected local function name.
%
% Revision 1.17  2003/12/09 23:24:18  michelich
% Evaluate preStimMeanSpecifier in a local function also.
%
% Revision 1.16  2003/12/09 23:19:47  michelich
% Made local functions for dataFileSpec and roiFileSpec evaulation such that
% other variables do not influence eval results (e.g. using gyri{gyrus} in a
% dataFileSpec).  Also report better error messages.
%
% Revision 1.15  2003/10/22 15:54:39  gadde
% Make some CVS info accessible through variables
%
% Revision 1.14  2003/09/08 19:34:23  michelich
% Check that number of stat functions & headers match.
%
% Revision 1.13  2003/09/08 17:16:42  michelich
% Added backwards compatibility note.
%
% Revision 1.12  2003/09/08 17:15:23  michelich
% Michael Wu's update for BXH compatibility:
% Updated help on typeSpec and examples for using BXH.
% Changed params to typeSpec.
% Added backward compatibility for the old params format.
%
% Revision 1.11  2003/03/28 21:16:12  michelich
% Updated comments.  Corrected case of roistats.
%
% Revision 1.10  2003/03/27 21:50:55  michelich
% Updated comments.
% Initiate Excel closer to the time it is used.
% Change case of preStimMeanDataSpec for consistency.
%
% Revision 1.9  2003/02/03 19:43:52  michelich
% Added optional output argument containing excel data for easier testing.
% Changed toexcel to all lowercase.
% Added punctuation to argument checking error messages.
% Changed progress bar message to match other roianalysis_* functions.
% Small whitespace changes.
%
% Revision 1.8  2002/12/31 22:14:59  michelich
% Fixed typos and updated example.
%
% Revision 1.7  2002/12/03 21:01:26  michelich
% Optionally pass slices as a cell array of strings.
% Added ability to save excel file in a different path.
%
% Revision 1.6  2002/11/26 16:19:09  michelich
% Bug Fix: Used incorrected variable name for loading prestim data.
%
% Revision 1.5  2002/11/26 14:32:37  michelich
% Changed deprecated isstr to ischar
%
% Revision 1.4  2002/11/26 14:18:08  michelich
% Fixed typo
%
% Revision 1.3  2002/10/27 22:05:53  michelich
% Updated description
%
% Revision 1.2  2002/10/25 03:04:52  michelich
% Added checking of subBaselineForPerChange argument
%
% Revision 1.1  2002/10/25 01:51:27  michelich
% Original CVS import
%
%
% Pre CVS History Entries:
% Charles Michelich, 2002/10/24. Converted into function from roiAnalysisScript_tstatprofilemean.m
%                                Added ability to calculate prestimmean using either a vector of 
%                                  time points or a filename specifier.
%                                Added ability to chose whether or not to subtract prestimulus
%                                  baseline when calculating percent signal change.
%                                Set defaults for ranges,decDigits,userStatFuncs,
%                                  userHeaders,subBaselineForPerChange
% Charles Michelich, 2002/02/11. Changed to get baseline mean from a separate volume (preStimMeanFileSpec)
% Charles Michelich, 2001/10/30. Changed {bins{bin}} to bins(bin) is labeling of bins
% Charles Michelich, 2001/10/18. Changed construction of  binStr to use string bin label
%                                Changed to use iscellstr (instead of iscell) for checking studies,gyri,sides,bins
% Charles Michelich, 2001/06/20. Modified to use cell array of bins to support text bin labels
% Francis Favorini,  2000/05/11. In catch block, clear all variables except emsg.
% Francis Favorini,  2000/05/09. Use clear all at beginning and private toexcel with Cleanup at end.
% Francis Favorini,  2000/05/08. Output stats for union of all maskBins for each range separately.
% Francis Favorini,  2000/05/05. Make sure each ROI file contains a valid ROI.
%                                Output stats for all maskBins.
%                                Fixed bug: was using ~= instead of isequal to compare baseSizes.
%                                Output stats for union of all maskBins.
% Francis Favorini,  2000/05/04. Added optional ranges to load masked ROIs.
%                                Added userStatFuncs.
%                                Use %.*d to output ranges with decDigits digits of precision.
%                                Updated some error messages/checks.
%                                Changed the way the headers are done.
%                                Allow user to specify [] for zoom.
% Charles Michelich, 2000/02/22. Changed order of columns to put mean at right side with other data
% Charles Michelich, 2000/02/18. Took out studies{study} from constuction of names for more flexibility
% Charles Michelich, 2000/02/16. Eliminated roibaseSize input argument (automatically read now)
%                                Changed string in progress bar to a more clear description
%                                Added check on input parameters
%                                Added progress bar for loading of ROIs and generation of dataProto
%                                Added squeeze(currdata) for new output format of ROIStats
% Charles Michelich, 2000/02/15. Changed name to roiAnalysisScript.m from roiAnalysisScript_roistats2.m
%                                Changed to use roiStats (with multiple passed rois)
%                                Changed study, gyrus, side, bin, slice to counters
% Charles Michelich, 2000/02/15. Changed name to roiAnalysisScript_roistats2.m from roiScriptNewInterp2.m
%                                Updated descriptions for submission into BIAC example scripts
%                                Added progress bar to interpolation and each total roi's processed
%                                Moved check for correct number of time points before interpolation
%                                Corrected length of output array (I had included length(bins) twice)
% Charles Michelich, 2000/01/14. Added Check for all ROI files before processing
%                                Added output of baseline mean and percent signal change
% Charles Michelich, 2000/01/11. original.  Adapted from roiscript
%                                Implemented as script until good function form can be determined
