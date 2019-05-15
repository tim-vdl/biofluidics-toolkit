function dicomrename(fpathin, fnames, action, stringname, stringformat)
% DICOMRENAME Rename DICOM-files based on the value of fields in the header
%    DICOMRENAME will present the user with a dialog to select either DICOM 
%    files or the Siemens implementation of DICOM IMA. It will rename the 
%    files based on info in the header of the file using a default naming 
%    schema defined in the first few lines of source code of this function. 
%
%    DICOMRENAME(PATH, FILES) will do the same as explained above using the
%    files supplied as an argument to the function. FILES should be a cell 
%    array of filenames. PATH should be a character array. Similar to the 
%    Matlab native function UIGETFILE using the option 'MultiSelect','On' 
%    or when using one of the functions WILDCARDSEARCH or REGEXPDIR.
% 
%    Example:
%     fpath = 'c:\test\';
%     fnames = {'MRPATIENT.MR.FANCY_STUDY.2.11.2009.01.22.17.08.15.9215.IMA', ...
%               'MRPATIENT.MR.FANCY_STUDY.2.12.2009.01.22.17.08.15.9875.IMA'};
%     dicomrename(fpath, fnames);
%    
%    DICOMRENAME(PATH, FILES, ACTION) the extra optional argument ACTION 
%    allows the user to specify the action. Options are 'rename' the file 
%    or create a 'copy' of the file. The default action is 'copy'. The 
%    original file name will not be preserved and cannot be restored unless 
%    it is already stored as a field in the DICOM header. 
%
%    Example:
%     fpath = 'c:\test\';
%     fnames = {'MRPATIENT.MR.FANCY_STUDY.2.11.2009.01.22.921875.13574960.IMA', ...
%               'MRPATIENT.MR.FANCY_STUDY.2.12.2009.01.22.921875.13574960.IMA'};
%     dicomrename(fpath, fnames, 'rename');
%
%    DICOMRENAME(PATH, FILES, ACTION, STRINGNAME) the optional argument
%    STRINGNAME allows the user to specify the naming convention to be used
%    based on available fields in the DICOM header. By default the fields
%    'PatientName.FamilyName','SeriesDescription', 'SeriesNumber' and 
%    'InstanceNumber' are used. These correspond to common fields in the 
%    Siemens MRI DICOM implementation (as current in 2009). Have a look at 
%    the source code of this function on how to use or (permanently) change
%    this option. Use the function DICOMINFO to get a list of the available
%    fields for your DICOM files. 
%
%    DICOMRENAME(PATH, FILES, ACTION, STRINGNAME, STRINGFORMAT) the extra 
%    optional argument STRINGFORMAT allows the user to specify the 'post'- 
%    reading formatting of every field individually. As STRINGNAME, the
%    field STRINGFORMAT is a cell array of strings. The strings are 
%    evaluated at runtime. The simplest method directs the read field 
%    directly to the name part without any further processing. Escape names
%    for the fields are <in> for the value read from the header and <out> 
%    for the string to be included in the filename. See the source code for
%    an eloborate example. 
%
%    For more info on this function and how to use it, bug reports, feature
%    requests, etc. feel free to contact the author.
%
%    See also DICOMINFO, WILDCARDSEARCH, REGEXPDIR

%==========================================================================
% B.C. Hamans (b.c.hamans@rad.umcn.nl) http://www.hamans.com/mri       2009       
%==========================================================================

%==========================================================================
%           UPDATE THE VARIABLES BELOW FOR YOUR DICOM FILES
%==========================================================================

% Separator of field names in the output file name. 
% Examples: .-_~  Not allowed: \/:*?"<>|
separator = '.';

% Array of DICOM header elements to use for file naming
namestring = {'PatientName.FamilyName',...
              'SeriesDescription',...
              'SeriesNumber',...
              'InstanceNumber'}; 
% Default for Siemens IMA: namestring = {'PatientName.FamilyName',...
%                                        'SeriesDescription',...
%                                        'SeriesNumber',...
%                                        'InstanceNumber'};           

% Array of formatting for the elements
formatstring = {'<out>=<in>;',... 
                '<out>=<in>;',... 
                '<out>=num2str(100+<in>);<out>=<out>(2:3);',...
                '<out>=num2str(1000+<in>);<out>=<out>(2:4);'}; 
% Default for Siemens IMA: formatstring = {'<out>=<in>;',... 
%                                          '<out>=<in>;',... 
%                           '<out>=num2str(100+<in>);<out>=<out>(2:3);',...
%                           '<out>=num2str(1000+<in>);<out>=<out>(2:4);'}; 
            
% Examples regarding the 'formatstring' variable or STRINGFORMAT argument
%  '<out>=<in>;' Simplest form
%  '<out>=strcat(''NAME='',<in>);' Prepends the string 'NAME='. Notice the 
%                                  double quotes! 
%  '<out>=strcat(''TE='',num2str(<in>),''ms'');' Prepends the string 'TE=' 
%                                                converts the echo time to 
%                                                a string and appends the 
%                                                string 'ms'. Note that the
%                                                <in> did not have the
%                                                class character.
%  '<out>=num2str(1000+<in>);<out>=<out>(2:4);'}; Prepend zeros to get 
%                                                 001 to 010 etc instead of
%                                                 1 to 10
% Not allowed characters in any string: \/:*?"<>|
            
%==========================================================================
%           DO NOT CHANGE CODE BELOW THIS LINE FOR NORMAL USAGE
%==========================================================================

% Check arguments
if nargin < 5
    stringformat = formatstring;
    if nargin < 4
        stringname = namestring; 
        if nargin < 3
            action = 'copy';
            if nargin == 1
                error(nargchk(2,2, nargin));
            elseif nargin == 0 
                [fnames, fpathin] = uigetfile(...
                    {'*.dcm;*.ima', 'Compatible files (*.dcm; *.ima)';...
                    '*.dcm', 'DICOM Files (*.dcm)';...
                    '*.ima', 'Siemens IMA Files (*.ima)';...
                    '*.*','All files (*.*)';},...
                    'Open', 'MultiSelect', 'on');    
                if isequal(fnames,0)
                    return 
                end
            end
        end
    end
else
    error(nargchk(0,5, nargin));
end

%==========================================================================

% Loop through all files in fnames
if ~iscell(fnames) 
    fnames={fnames};
end
for i=1:length(fnames)
    namestring = stringname;
    [fpath,fname,fext] = fileparts(fullfile(fpathin,cell2mat(fnames(i))));
    disp(strcat('Reading: <a href="', fullfile(fpath,strcat(fname,fext)),...
        '">', fullfile(fpath,strcat(fname,fext)), '</a>'));
    
    % Read dicom header
    dinfo=dicominfo(fullfile(fpath,strcat(fname,fext)));
    
    % Construct the new file name
    newfname = '';
    for j=1:length(namestring)        
        structname = 'dinfo';
        % Handle nested elements e.g. 'PatientName.FamilyName'
        namestr=cell2mat(namestring(j));
        if strfind(namestr, '.')
            while true
                [str, namestr] = strtok(namestr, '.');
                if isempty(namestr),
                    namestring(j) = {str};
                    break;  
                end
                structname = strcat(structname, '.', str);
            end
        end

        % Read the value of the field and perform the actions as defined in
        % STRINGFORMAT argument or 'formatstring' variable
        eval(cell2mat(strrep(strrep(stringformat(j),'<out>','newpart'),...
            '<in>','getfield(eval(structname),cell2mat(namestring(j)))'))); 
        newfname = strcat(newfname, separator, newpart);
    end
    newfname = newfname(length(separator)+1:length(newfname));
        
    % Copy
    disp(strcat('Writing: <a href="', fullfile(fpath,strcat(newfname,fext)),...
        '">', fullfile(fpath,strcat(newfname,fext)), '</a>'));
    try
        copyfile(fullfile(fpath,strcat(fname,fext)), fullfile(fpath,strcat(newfname,fext))); 
    catch
        error('Failed. Destination not writable? Illegal character in file name?')
    end
    
    % Remove if rename
    if strncmpi(action, 'rename', 4)
        disp(strcat('Removing: <a href="', fullfile(fpath,strcat(fname,fext)),...
            '">', fullfile(fpath,strcat(fname,fext)), '</a>'));
        try
            delete(fullfile(fpath,strcat(fname,fext)));
        catch
            error('Failed. Delete it by hand.');
        end
    end
end

%==========================================================================
% Changelog:
%  27-01-2009 v1.00 (BCH)  Initial release
%  29-01-2009 v1.1  (BCH)  Added functionality to format the name fields
%==========================================================================
