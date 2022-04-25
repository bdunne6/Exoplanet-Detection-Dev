function [rpath] = repo_root()
%REPO_ROOT returns the path to the repo root
mpath = mfilename('fullpath');
rpath = fileparts(fileparts(fileparts(mpath)));
end

