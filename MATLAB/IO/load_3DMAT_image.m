function result = load_3DMAT_image(fileName)
% Load variable 'sample' that is stored in the mat-file 'fileName'. The
% variable that you want to load must be called 'sample'.
% Sample is a 3D image volume
tmp = load(fileName, 'sample');
result = tmp.sample;