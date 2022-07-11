function toCourseWorkDIR()
% function toCourseWorkDIR()
%
% This function changes the working directory to the Course Work folder of the
% local GitHub repository.
%
%
% Author: Gary Hui Zhang (gary.zhang@ucl.ac.uk)
%         Michele Guerreri (m.guerreri@ucl.ac.uk)
%
%

% get this function's full path
thisFunctionFullPath = mfilename('fullpath');

% get the name of the directory where this function is
CodeDIR = fileparts(thisFunctionFullPath);

% change to the Codes folder
cd(CodeDIR)

% get the working directory relative path
wrkDir = fullfile('..', '..', 'doc', 'course_material');

% change to the working directory
cd(wrkDir)

%% end of function
end