#!/bin/bash
#
# img2mtz 

# Directorio de prueba.
# cd ~/data2/prueba

cd ~/data2
for i in asc cic nit sul tan n37 n47-d17 
	do
		cd $i
	for j in `ls -1` 
	do 
	cd "$j" 
	# Genera el XDS.INP
	generate_XDS.INP "$j"_001.img.bz2
	echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_ALPHA/BETA=13 >> XDS.INP 
	echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_GAMMA=13      >> XDS.INP 
	sed 's/_001.img.bz2/_???.img.bz2/' XDS.INP > a
       	sed 's/P_NUMBER=0/P_NUMBER=96/' a > b
       	sed 's/ANTS= 70 80 90 90 90 90/ANTS= 78 78 37 90 90 90/' b > c
       	sed 's/A_RANGE=/A_RANGE=1 100/' c > d
       	sed 's/T_RANGE=/T_RANGE=1 100/' d > XDS.INP
       	# Corre XDS
	rm a b c d ; xds_par
	# Corre los análisis
	xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
	echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
	# Corre XDSCONV 
	echo "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05" > XDSCONV.INP
	echo "INPUT_FILE=XDS_ASCII.HKL" >> XDSCONV.INP
	echo "OUTPUT_FILE=temp.hkl CCP4_I" >> XDSCONV.INP
	echo "FRIEDEL'S_LAW=FALSE" >> XDSCONV.INP
	xdsconv
	f2mtz HKLOUT temp.mtz<F2MTZ.INP
   	cad HKLIN1 temp.mtz HKLOUT out.mtz<<EOF
   	LABIN FILE 1 ALL
   	DWAVELENGTH FILE 1 1    0.93930
   	END
EOF
	# Corre XSCALE
	echo "OUTPUT_FILE=temp.ahkl" > XSCALE.INP
	echo "INPUT_FILE=XDS_ASCII.HKL" >> XSCALE.INP
	xscale_par
	cd ..
	done
	cd ..
done
# N57 es el único dataset con anillos de hielo
	cd ~/data2/n57
	for j in `ls -1` 
	do 
	cd "$j" 
	# Genera el XDS.INP
	generate_XDS.INP "$j"_001.img.bz2
	echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_ALPHA/BETA=13 >> XDS.INP 
	echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_GAMMA=13      >> XDS.INP 
	sed 's/_001.img.bz2/_???.img.bz2/' XDS.INP > a
       	sed 's/P_NUMBER=0/P_NUMBER=96/' a > b
       	sed 's/ANTS= 70 80 90 90 90 90/ANTS= 78 78 37 90 90 90/' b > c
       	sed 's/A_RANGE=/A_RANGE=1 100/' c > d
       	sed 's/T_RANGE=/T_RANGE=1 100/' d > e
	sed 's/!EXCLUDE_RESOLUTION_RANGE= 3.70 3.64/EXCLUDE_RESOLUTION_RANGE= 3.70 3.64/' e > f
	sed 's/!EXCLUDE_RESOLUTION_RANGE= 2.28 2.22/EXCLUDE_RESOLUTION_RANGE= 2.28 2.22/' f > g
	sed 's/!EXCLUDE_RESOLUTION_RANGE= 1.948 1.888/EXCLUDE_RESOLUTION_RANGE=1.948 1.888/'  g > XDS.INP
	# Corre XDS
	rm a b c d e f g ; xds_par
	# Corre los análisis
	xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
	echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
	# Corre XDSCONV 
	echo "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05" > XDSCONV.INP
	echo "INPUT_FILE=XDS_ASCII.HKL" >> XDSCONV.INP
	echo "OUTPUT_FILE=temp.hkl CCP4_I" >> XDSCONV.INP
	echo "FRIEDEL'S_LAW=FALSE" >> XDSCONV.INP
	xdsconv
	f2mtz HKLOUT temp.mtz<F2MTZ.INP
   	cad HKLIN1 temp.mtz HKLOUT out.mtz<<EOF
   	LABIN FILE 1 ALL
   	DWAVELENGTH FILE 1 1    0.93930
   	END
EOF
	# Corre XSCALE
	echo "OUTPUT_FILE=temp.ahkl" > XSCALE.INP
	echo "INPUT_FILE=XDS_ASCII.HKL" >> XSCALE.INP
	xscale_par
	cd ..
	done

