#!/bin/bash
#

cd /path/to/working/directory
for i in `seq -w 1 10` # or as many as you have!
do
cd $i
# Generates XDS.INP
generate_XDS.INP *_0001.cbf.bz2 # less error-prone
sed 's/_0001.cbf.bz2/_????.cbf.bz2/' XDS.INP > a # files are compressed
sed 's/P_NUMBER=0/P_NUMBER=96/' a > b # sg is known
sed 's/ANTS= 70 80 90 90 90 90/ANTS= 78 78 37 90 90 90/' b > c # also uc constants
sed 's/A_RANGE=/A_RANGE=1 270/' c > d # Do you know your data collection?
sed 's/T_RANGE=/T_RANGE=1 270/' d > e
sed 's/! BACKGROUND_RANGE=1 10/EXCLUDE_DATA_RANGE=91 180/' e > XDS.INP
xds_par # parallel version of xds
# Optimize according to the xds wiki
cp GXPARM.XDS XPARM.XDS
mv CORRECT.LP CORRECT.LP.old
sed 's/JOB= XYCORR INIT COLSPOT IDXREF DEFPIX INTEGRATE CORRECT/JOB= DEFPIX INTEGRATE CORRECT/' XDS.INP > f
mv f XDS.INP
xds_par # run xds again
# Now run the xdscc1/2
xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
# Generates mtz with r-free flags
printf "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05
INPUT_FILE=XDS_ASCII.HKL
OUTPUT_FILE=temp.hkl CCP4_I
FRIEDEL'S_LAW=TRUE" > XDSCONV.INP
xdsconv
f2mtz HKLOUT temp1.mtz<F2MTZ.INP
cad HKLIN1 temp1.mtz HKLOUT original_rfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF
# Generates mtz withou r-free flags
grep -v GENE XDSCONV.INP > g
mv g XDSCONV.INP
xdsconv
f2mtz HKLOUT temp2.mtz<F2MTZ.INP
cad HKLIN1 temp2.mtz HKLOUT original_norfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF

# Next i
cd ..
done
