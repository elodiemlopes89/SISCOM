# SISCOM
Pipeline of subtracted ictal SPECT (Single Photon Emission Computed Tomography) co-registered to MRI (Magnetic Resonance Image), to support clinicians during the presurgical evaluation of epilepsy

Pipeline developed under the PhD thesis "Novel Contributions to Personalized Brain Stimulation Biomarkers for Better Management of Neurological Disorders", supervised by Prof. João Paulo Cunha (INESC TEC, Porto, Portugal).

Doctoral Program of Biomedical Engineering (Faculty of Engineering of University of Porto).

References:
Oliveira, Ricardo Filipe Almeida. "Técnicas de subtracção de SPECT e seu coregisto com IRM: análise e optimização de um protocolo clínico e sua utilidade clínica em doentes epilépticos." (2005).



## Pipeline:

### 1. Conversion to NIfTI
Conversion of the ictal and interictal SPECT and the MRI for NIfTI.

Example: dcm2nii MATALB function (https://www.mathworks.com/matlabcentral/fileexchange/42997-xiangruili-dicm2nii).

### 2. Brain and neck extraction from MRI
Extract brain and neck from the MRI image, using FSL scripts.

Neck extraction:
>> robustfov -i bighead -r bighead_crop


### 3. Brain extraction from SPECT images

### 4. Normalization of SPECT images
Normalization of SPECT images using the FSL
>> FLIRT
>> Input: MRI brain
>> Transformation: Rigid body
>> Cost function: Normalized Mutual Information

### 5. Conversion of the normalized SPECTs to the Analyze format

Example: https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

### 6. Subtraction of SPECT images
Subtraction of SPECT interictal from SPECT ictal using the "subtracao_spects.m" function.

### 7. Conversion of the subtracted image to NIfTI
Conversion from Analyze to NIfTI, using the MATLAB command line
>> fslchfiletype NIFTI siscom.hdr

### 8. Co-registration of the subtracted image with the MRI brain
Co-registrration using the FSL:
>> FLIRT:
>> Reference image: MRI brain
>> Transformation: Rigid body
>> Cost function: Normalized Mutual Information

### 9. Intensity threshold
Set a intensity segmentation using the FSL command line:
>> fslmaths siscom.nii.gz –thr thr siscom_thr.nii.gz

thr (threshold) = 2*sigma
sigma = standard deviation of the siscom’s intensity matrix

### 10. Multiplication of the subtracted image by the patient’s brain
Multiplication of the substracted image using the FSL command line:
>> fslmaths brain.nii.gz –mul siscom_thr.nii.gz siscom_final.nii.gz

brain.nii.gz: MRI's brain
siscome_final.nii.gz: substracted image after NIfTI conversion and intensity threshold segmentation.

### 11. Output visualization
Visualization of the multiplied image, overlaied on the patient's brain.










