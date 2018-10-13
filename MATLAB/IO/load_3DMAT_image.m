function result = load_3DMAT_image(fileName) 

    % Load variable 'sample' that is stored in the mat-file 'fileName')
    % Sample is a 3D image volume
    tmp = load(fileName, 'sample');
    result = tmp.sample; 