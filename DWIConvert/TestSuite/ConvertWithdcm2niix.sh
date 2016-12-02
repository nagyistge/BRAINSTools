#!/bin/bash -e -x
# \author Hans J. Johnson

## TODO: READ THIS: http://neurohut.blogspot.com/2015/11/how-to-extract-bval-bvec-from-dicom.html

make -j 4
if [[ $? -ne 0 ]]; then
  echo "FAILURE TO BUILD"
  exit -1 
fi
test_name=test10

bdir=/Users/johnsonhj/src/BT-11/BRAINSTools-build/DWIConvert
make -C ${bdir}

source  ${FSLDIR}/etc/fslconf/fsl.sh

mkdir -p ~/src/dcm2niix-bld install
mkdir -p ~/src/BT-11/BRAINSTools-build/DWIConvert

DICOM_LIST="DTI_004 GeSignaHDx GeSignaHDxBigEndian GeSignaHDxt PhilipsAchieva1 PhilipsAchieva2 PhilipsAchieva3 PhilipsAchieva4 PhilipsAchieva6 PhilipsAchieva7 PhilipsAchievaBigEndian1 SiemensTrio-Syngo2004A-1 SiemensTrio-Syngo2004A-2 SiemensTrioTim1 SiemensTrioTim2 SiemensTrioTim3 SiemensTrioTimBigEndian1 SiemensVerio"
DICOM_LIST="SiemensTrioTim1 SiemensTrioTim2 SiemensTrioTim3 SiemensTrioTimBigEndian1 SiemensVerio"
#DICOM_LIST="GeSignaHDx"
DICOM_LIST="DTI_004"

for dicomDir in $(echo ${DICOM_LIST}); do
  outdir=$(pwd)/${test_name}/${dicomDir}
  mkdir -p ${outdir}
  cp $0 ~/Dropbox/Downloads

  ~/src/BT-11/DCMTK-build/bin/dcm2xml $(find $(pwd)/${dicomDir} |head -n 2 |tail -n 1) > ${outdir}/SecondFile.xml

cp ~/Desktop/tt.nii.gz ${outdir}/T1.nii.gz

echo "================="
echo "================="
echo "================="
echo "================="

if [[ 1 -eq 1 ]] ; then
  /opt/dcm2niix/bin/dcm2niix -m -b y -t y -v y -z i  -o ${outdir} -f "${dicomDir}" ${dicomDir} 
  ~/src/BT-11/BRAINSTools-build/BRAINSCommonLib/TestSuite/testbin/DumpImageInfo 4 ${outdir}/${dicomDir}.nii.gz > ${outdir}/${dicomDir}.nii_itk
   /opt/Clibs/bin/nifti_tool -disp_hdr -in ${outdir}/${dicomDir}.nii.gz > ${outdir}/${dicomDir}.nii_nifti
  /Users/johnsonhj/src/BT-11/bin/DWIConvert \
        --conversionMode FSLToNrrd \
        --useIdentityMeaseurementFrame \
        --inputVolume ${outdir}/${dicomDir}.nii.gz \
        --outputDirectory ${outdir} \
        --outputVolume NIIX${dicomDir}.nhdr
  ~/src/BT-11/BRAINSTools-build/BRAINSCommonLib/TestSuite/testbin/DumpImageInfo 4 ${outdir}/NIIX${dicomDir}.nhdr > ${outdir}/NIIX${dicomDir}.nhdr_itk
  ~/src/NEP-11/bin/dtiestim  --inputDWIVolume ${outdir}/NIIX${dicomDir}.nhdr --outputDTIVolume ${outdir}/NIIX${dicomDir}_DTI.nhdr
  mkdir -p ${outdir}/NIIX_dti
  bet2 ${outdir}/${dicomDir}.nii.gz ${outdir}/NIIX_dti/mask.nii
  /opt/fsl/bin/dtifit \
    --data=${outdir}/${dicomDir}.nii.gz \
    --out=${outdir}/NIIX_dti/NIIX_ \
    --mask=${outdir}/NIIX_dti/mask.nii.gz \
    --bvecs=${outdir}/${dicomDir}.bvec \
    --bvals=${outdir}/${dicomDir}.bval \
    --wls \
    --sse \
    --save_tensor

  
  
fi

if [[ 1 -eq 1 ]] ; then
  /Users/johnsonhj/src/BT-11/bin/DWIConvert \
        --conversionMode DicomToNrrd \
        --useIdentityMeaseurementFrame \
        --inputDicomDirectory ${dicomDir} \
        --outputDirectory ${outdir} \
        --outputVolume DWI${dicomDir}.nhdr
  ~/src/BT-11/BRAINSTools-build/BRAINSCommonLib/TestSuite/testbin/DumpImageInfo 4 ${outdir}/DWI${dicomDir}.nhdr > ${outdir}/DWI${dicomDir}.nhdr_itk
  ~/src/NEP-11/bin/dtiestim  --inputDWIVolume ${outdir}/DWI${dicomDir}.nhdr --outputDTIVolume ${outdir}/DWI${dicomDir}_DTI.nhdr
fi

if [[ 1 -eq 1 ]] ; then
  /Users/johnsonhj/src/BT-11/bin/DWIConvert \
        --conversionMode DicomToFSL \
        --useIdentityMeaseurementFrame \
        --inputDicomDirectory ${dicomDir} \
        --outputDirectory ${outdir} \
        --outputVolume DWI${dicomDir}.nii
  ~/src/BT-11/BRAINSTools-build/BRAINSCommonLib/TestSuite/testbin/DumpImageInfo 4 ${outdir}/DWI${dicomDir}.nii > ${outdir}/DWI${dicomDir}.nii_itk
   /opt/Clibs/bin/nifti_tool -disp_hdr -in ${outdir}/DWI${dicomDir}.nii > ${outdir}/DWI${dicomDir}.nii_nifti
   /Users/johnsonhj/src/BT-11/bin/BFileCompareTool ${outdir}/${dicomDir}.bvec ${outdir}/DWI${dicomDir}.bvec 3 1e-2 > ${outdir}/bvec_compare.output

  mkdir -p ${outdir}/DWIConvert_dti
  bet2 ${outdir}/DWI${dicomDir}.nii.gz ${outdir}/DWIConvert_dti/mask.nii
  /opt/fsl/bin/dtifit \
    --data=${outdir}/DWI${dicomDir}.nii.gz \
    --out=${outdir}/DWIConvert_dti/DWIdti_ \
    --mask=${outdir}/DWIConvert_dti/mask.nii.gz \
    --bvecs=${outdir}/DWI${dicomDir}.bvec \
    --bvals=${outdir}/DWI${dicomDir}.bval \
    --wls \
    --sse \
    --save_tensor
fi

if [[ 1 -eq 1 ]] ; then
  /Users/johnsonhj/src/BT-11/bin/DWIConvert \
        --conversionMode FSLToNrrd \
        --useIdentityMeaseurementFrame \
        --inputVolume ${outdir}/DWI${dicomDir}.nii \
        --outputDirectory ${outdir} \
        --outputVolume Recovered${dicomDir}.nhdr
  ~/src/BT-11/BRAINSTools-build/BRAINSCommonLib/TestSuite/testbin/DumpImageInfo 4 ${outdir}/Recovered${dicomDir}.nhdr > ${outdir}/Recovered${dicomDir}.nhdr_itk
fi
done

