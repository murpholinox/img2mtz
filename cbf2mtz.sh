#!/bin/bash
#

cd /home/murphy/Documents/21june2021/4.5
for i in `seq -w 1 10` 
do
cd $i
# Genera el XDS.INP
generate_XDS.INP *_0001.cbf.bz2
sed 's/_0001.cbf.bz2/_????.cbf.bz2/' XDS.INP > a
sed 's/P_NUMBER=0/P_NUMBER=96/' a > b
sed 's/ANTS= 70 80 90 90 90 90/ANTS= 78 78 37 90 90 90/' b > c
sed 's/A_RANGE=/A_RANGE=1 270/' c > d
sed 's/T_RANGE=/T_RANGE=1 270/' d > e
sed 's/! BACKGROUND_RANGE=1 10/EXCLUDE_DATA_RANGE=91 180/' e > XDS.INP
xds_par
# Optimiza 
cp GXPARM.XDS XPARM.XDS
mv CORRECT.LP CORRECT.LP.old
sed 's/JOB= XYCORR INIT COLSPOT IDXREF DEFPIX INTEGRATE CORRECT/JOB= DEFPIX INTEGRATE CORRECT/' XDS.INP > f
mv f XDS.INP
xds_par
# Corre los análisis
xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
# Siguiente i
cd ..
done

cd /home/murphy/Documents/21june2021/9.5
for i in `seq -w 1 10` 
do
cd $i
# Genera el XDS.INP
generate_XDS.INP *_0001.cbf.bz2
sed 's/_0001.cbf.bz2/_????.cbf.bz2/' XDS.INP > a
sed 's/P_NUMBER=0/P_NUMBER=96/' a > b
sed 's/ANTS= 70 80 90 90 90 90/ANTS= 78 78 37 90 90 90/' b > c
sed 's/A_RANGE=/A_RANGE=1 270/' c > d
sed 's/T_RANGE=/T_RANGE=1 270/' d > e
sed 's/! BACKGROUND_RANGE=1 10/EXCLUDE_DATA_RANGE=91 180/' e > XDS.INP
xds_par
# Optimiza 
cp GXPARM.XDS XPARM.XDS
mv CORRECT.LP CORRECT.LP.old
sed 's/JOB= XYCORR INIT COLSPOT IDXREF DEFPIX INTEGRATE CORRECT/JOB= DEFPIX INTEGRATE CORRECT/' XDS.INP > f
mv f XDS.INP
xds_par
# Corre los análisis
xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
# Siguiente i
cd ..
done

# Se genera el archivo mtz para el dataset inicial
cd /home/murphy/Documents/21june2021/4.5/01
# Genera mtz con r-free flags
printf "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05
INCLUDE_RESOLUTION_RANGE=50 1.15
INPUT_FILE=XDS_ASCII.HKL
OUTPUT_FILE=cut.hkl CCP4_I
FRIEDEL'S_LAW=TRUE" > XDSCONV.INP
xdsconv
f2mtz HKLOUT cut.mtz<F2MTZ.INP
cad HKLIN1 cut.mtz HKLOUT cut_rfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF
# Reemplazo molecular y primer afinamiento
cd /home/murphy/Documents/21june2021/4.5/01
phenix.phaser cut_rfree.mtz ../../1iee.pdb ../../hewl.fasta
phenix.refine PHASER.1.pdb cut_rfree.mtz ordered_solvent=true primary_map_cutoff=5 optimize_xyz_weight=true optimize_adp_weight=true nproc=8 output.prefix=45 adp.randomize=true adp.convert_to_anisotropic=true new_solvent=anisotropic

# Se genera el archivo mtz para el dataset inicial
cd /home/murphy/Documents/21june2021/9.5/01
# Genera mtz con r-free flags
printf "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05
INCLUDE_RESOLUTION_RANGE=50 1.10
INPUT_FILE=XDS_ASCII.HKL
OUTPUT_FILE=cut.hkl CCP4_I
FRIEDEL'S_LAW=TRUE" > XDSCONV.INP
xdsconv
f2mtz HKLOUT cut.mtz<F2MTZ.INP
cad HKLIN1 cut.mtz HKLOUT cut_rfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF

for i in `seq -w 02 10`
do
cd /home/murphy/Documents/21june2021/4.5
cd $i
# Genera mtz con r-free flags
printf "INHERIT_TEST_REFLECTIONS_FROM_FILE=../01/cut.hkl SHELX
INCLUDE_RESOLUTION_RANGE=50 1.15
INPUT_FILE=XDS_ASCII.HKL
OUTPUT_FILE=cut.hkl CCP4_I
FRIEDEL'S_LAW=TRUE" > XDSCONV.INP
xdsconv
f2mtz HKLOUT cut.mtz<F2MTZ.INP
cad HKLIN1 cut.mtz HKLOUT cut_rfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF
cd ..
done

for i in `seq -w 02 10`
do
cd /home/murphy/Documents/21june2021/9.5
cd $i
# Genera mtz con r-free flags
printf "INHERIT_TEST_REFLECTIONS_FROM_FILE=../01/cut.hkl SHELX
INPUT_FILE=XDS_ASCII.HKL
OUTPUT_FILE=cut.hkl CCP4_I
FRIEDEL'S_LAW=TRUE" > XDSCONV.INP
xdsconv
f2mtz HKLOUT cut.mtz<F2MTZ.INP
cad HKLIN1 cut.mtz HKLOUT cut_rfree.mtz<<EOF
LABIN FILE 1 ALL
DWAVELENGTH FILE 1 1    0.979
END
EOF
cd ..
done


