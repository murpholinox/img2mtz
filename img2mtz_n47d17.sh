#!/bin/bash
# 
# Desde `*.img` hasta el `*.mtz`.
# 1) Genera XDS.INP y corre xds_par
# 2) Optimiza de acuerdo a http://strucbio.biologie.uni-konstanz.de/xdswiki/index.php/Optimisation
# 3) Guarda el ISa para compararlo con el viejo.
# 4) Corre xdsstat y un pequeño script de gnuplot para graficar el Rd. Luego corre xdscc12
# 5) Al final corre xdsconv para generar el MTZ con I(+), SIGI(+), I(-), SIGI(-).
# murpholinox@gmail.com
for i in `seq -w 01 17`
do
  cd /home/murpho0/Documents/rel_tes/data/n47-d17/d"$i"
  generate_XDS.INP d"$i"_001.img 
  sed -e "s:NAME_TEMPLATE_OF_DATA_FRAMES=./d${i}_001.img:NAME_TEMPLATE_OF_DATA_FRAMES=./d${i}_???.img:" -e 's:DATA_RANGE=:DATA_RANGE=1 100:' -e 's:SPOT_RANGE=:SPOT_RANGE=1 100:' XDS.INP > a
  mv a XDS.INP
  xds_par 
  mkdir no_opt
  cp -p *.cbf *.LP *.XDS *.HKL no_opt/  
  cp -p CORRECT.LP CORRECT.LP.old 
  grep _E INTEGRATE.LP | tail -2 > x 
  sed -e 's/BEAM_DIVERGENCE=/!BEAM_DIVERGENCE=/' -e 's/REFLECTING_RANGE=/!REFLECTING_RANGE=/' XDS.INP >>x 
  mv x XDS.INP 
  grep -v "REFINE(IN" XDS.INP > x 
  echo "REFINE(INTEGRATE)= ! empty list" > XDS.INP 
  cat x >> XDS.INP
  cp GXPARM.XDS XPARM.XDS
  sed 's:    89     :    96     :' XPARM.XDS > a
  mv a XPARM.XDS 
  egrep -v 'JOB' XDS.INP > XDS.INP.new
  echo "JOB=INTEGRATE CORRECT" > XDS.INP
  echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_ALPHA/BETA=13 >> XDS.INP 
  echo NUMBER_OF_PROFILE_GRID_POINTS_ALONG_GAMMA=13      >> XDS.INP 
  cat XDS.INP.new >> XDS.INP
  uc=`grep UNIT_CELL_CONSTANTS CORRECT.LP.old | tail -n 1`
  sed -e 's:SPACE_GROUP_NUMBER=0:SPACE_GROUP_NUMBER=96:' -e "s:UNIT_CELL_CONSTANTS= 70 80 90 90 90 90:${uc}:" XDS.INP > a
  mv a XDS.INP 
  xds_par 
  grep -A 1 "a        b          ISa" CORRECT.LP.old | awk '{print $3}' | tail -n 1 > Isa_old
  grep -A 1 "a        b          ISa" CORRECT.LP | awk '{print $3}' | tail -n 1 > Isa_opt
  paste Isa_old Isa_opt > Isa_old_opt 
  echo XDS_ASCII.HKL | xdsstat 1000 1 > XDSSTAT.LP
  grep DIFFERENCE XDSSTAT.LP > Rd
  cp /home/murpho0/Documents/rel_tes/plts/plot_Rd.plt .
  gnuplot plot_Rd.plt
  grep  "m               =" fit.log | awk '{print $3}' > m_Rd
  xdscc12 -cdef -nbin 3 -t 1 XDS_ASCII.HKL > XDSCC12.LP
  echo "INPUT_FILE=XDS_ASCII.HKL" > XDSCONV.INP
  echo "OUTPUT_FILE=temp.hkl CCP4_I" >> XDSCONV.INP
  echo "FRIEDEL'S_LAW=FALSE" >> XDSCONV.INP
  echo "GENERATE_FRACTION_OF_TEST_REFLECTIONS=0.05" >> XDSCONV.INP
  xdsconv
  f2mtz HKLOUT temp.mtz<F2MTZ.INP
   cad HKLIN1 temp.mtz HKLOUT out.mtz<<EOF
   LABIN FILE 1 ALL
   DWAVELENGTH FILE 1 1    0.93930
   END
EOF

done 

