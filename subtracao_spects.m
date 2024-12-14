% MATLAB Script for Processing SPECT (Single Photon Emission Computed Tomography) Images
% This script computes the normalization of SPECT images, subtracts interictal from ictal
% images, and saves the result as a SISCOM (Subtraction Ictal SPECT Co-registered to MRI) file.
% The script uses SPM (Statistical Parametric Mapping) toolbox for image processing.

% Author: Elodie M. Lopes
% PhD Thesis: Novel Contributions to Personalized Brain Stimulation Biomarkers for Better Management of Neurological Disorders
% Doctoral Program of Biomedical Engineering (Faculty of Engineering of University of Porto)
% Supervisor: João P. Cunha (INESC TEC, Porto, Portugal)
% Year: 2024

%References:
%Oliveira, Ricardo Filipe Almeida. "Técnicas de subtracção de SPECT e seu coregisto com IRM: %análise e optimização de um protocolo clínico e sua utilidade clínica em doentes epilépticos." %(2005).

clear all 
clc        

%% Step 1: Initiate SPM toolbox
% The script starts by setting the path to the SPM toolbox and loading it into the MATLAB environment.
% SPM (Statistical Parametric Mapping) is a software package used for the analysis of brain imaging data.

dir_spm = '...';  % Path to the SPM installation folder
addpath(dir_spm)  % Add SPM directory to MATLAB path
savepath dir_spm  % Save the path to MATLAB for future sessions

spm  % Initialize the SPM toolbox

%% Step 2: Compute the average and standard deviation of ictal and interictal SPECT images
% This section loads and processes two SPECT images:
% - 'fictal_norm.img' for ictal data (seizure event)
% - 'finterictal_norm.img' for interictal data (normal brain activity between seizures)

dir = pwd;  % Get the current working directory
Pat = 'Pat01';  % Define the patient identifier (modify as necessary)
Data_dir = [pwd, '/Data/', Pat];  % Define the path to the patient's data directory

% Load the ictal image (seizure data)
P = [];
P = [Data_dir, '/hdr_img/fictal_norm.img'];  % File path to the ictal SPECT image
Y = spm_vol(P);  % Read the header information of the image
img = spm_read_vols(Y);  % Read the image volume (intensity matrix)

% Compute the average and standard deviation of the ictal image intensities
media1 = mean(img(:));  % Mean intensity of the ictal image
desvp1 = std(img(:));   % Standard deviation of the ictal image intensities

% Create a matrix of zeros with the same size as the input image
[x, y, z] = size(img);  % Get the dimensions of the image (x, y, z)
h = zeros(x, y, z);  % Initialize a matrix of zeros with the same size

% Generate a matrix with the average value of the image
h1 = h + media1;  % Add the mean value to the matrix

Factor = 1000;  % Scaling factor for normalization
% Normalize the image by subtracting the mean and dividing by the standard deviation, then scale
resultado_final1 = ((img - h1) ./ desvp1) * Factor;

% Load the interictal image (normal brain activity)
W = [];
W = [Data_dir, '/hdr_img/finterictal_norm.img'];  % File path to the interictal SPECT image
X = spm_vol(W);  % Read the header information of the image
img = spm_read_vols(X);  % Read the interictal image volume

% Compute the average and standard deviation of the interictal image intensities
media2 = mean(img(:));  % Mean intensity of the interictal image
desvp2 = std(img(:));   % Standard deviation of the interictal image intensities

% Create a matrix of zeros with the same size as the interictal image
h = zeros(x, y, z);  % Initialize a matrix of zeros with the same size

% Generate a matrix with the average value of the interictal image
h2 = h + media2;  % Add the mean value to the matrix

Factor = 1000;  % Scaling factor for normalization
% Normalize the interictal image
resultado_final2 = ((img - h2) ./ desvp2) * Factor;

%% Step 3: Subtract interictal from ictal images to generate SISCOM result
% Subtract the interictal normalized image from the ictal normalized image
resultado_final = resultado_final1 - resultado_final2;  % SISCOM result: ictal - interictal

% Define the image to write the result to
if size(W) > 0
    K = X;   % Use the interictal header if the file exists
elseif size(P) > 0
    K = Y;   % Use the ictal header if the file exists
else
    K = 0;   % Default case if no valid header found
end

% Initialize an empty result volume to store the SISCOM output
s = size(resultado_final);  % Get the dimensions of the result
res = zeros(s(1), s(2), s(3));  % Initialize an empty matrix with the same dimensions

% Copy the processed data into the result volume
for i = 1:s(3)
    res(:, :, i) = resultado_final(:, :, i);  % Copy slice-by-slice
end

% Set the filename and header information for the output image
K.fname = [dir, '/siscom.img'];  % Define the output filename
K.dim = [size(res)];  % Set the output image dimensions
K.pinfo = [1; 0; 0];  % Set the data scaling information
K = spm_write_vol(K, res);  % Write the result to disk

%% Step 4: Check Registration of SISCOM Result with Brain Image
% This section checks the alignment of the SISCOM result with the brain image
img1 = [Data_dir, '/hdr_img/fbrain_brain.img'];  % Path to the brain image
img2 = [dir, '/siscom.img'];  % Path to the SISCOM result image

% Display both images together for visual inspection of their registration
s = char(img1, img2);  % Combine the paths of both images
spm_check_registration(s);  % Use SPM to check the registration between images

%% Step 5: Compute and Display Statistics for the SISCOM Image
% Compute statistics (mean and standard deviation) for the SISCOM image

T = [];  
T = [dir, '/siscom.img'];  % Path to the SISCOM image
Z = spm_vol(T);  % Read the header information of the SISCOM image
img = spm_read_vols(Z);  % Read the image volume

% Compute the mean and standard deviation of the SISCOM image intensities
mediaf = mean(img(:));  % Mean intensity of the SISCOM image
desvpf = std(img(:));   % Standard deviation of the SISCOM image intensities

%% Step 6: Visualize the Output
% Visualize the output SISCOM image alongside a thresholded version for better inspection

img1 = [Data_dir, '/hdr_img/ft1.img'];  % Path to a reference brain image
img2 = [Data_dir, '/hdr_img/fsiscom_thr.img'];  % Path to a thresholded SISCOM image

% Display the images together to inspect the result
s = char(img1, img2);  % Combine the paths of both images
spm_check_registration(s);  % Check the registration of both images
