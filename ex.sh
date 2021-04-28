#!/bin/bash

export PATH=/public/tools/lib/nco/bin:$PATH

fname="wrfout_d01_2021-04-24.nc"

arr_var1=("QICE" "QSNOW" "QRAIN" "QCLOUD" "QGRAUP")

for var1 in ${arr_var1[@]}
do
  echo ${var1}
  rm ${var1}.nc
  ##no times xlat xlong
  ncks -d Time,0 -C -v ${var1} ${fname} ${var1}.nc
  cp ${var1}.nc ${var1}temp.nc
  ## all including
  #ncks -C -v ${var1},Times,XLAT,XLONG ${fname} ${var1}.nc
  #cp ${var1}.nc ${var1}temp.nc
done
#temp
rm LATLON.nc Time.nc
ncks -d Time,0 -C -v XLAT,XLONG ${fname} LATLON.nc
ncks -d Time,0 -v Times ${fname} Time.nc

arr_var2=("Ice" "Snow" "Rain" "Cloud" "Graupel")
for ((i=0;i<5;i++));
do
  echo ${arr_var2[i]}
  ncrename -v ${arr_var1[i]},${arr_var2[i]} ${arr_var1[i]}.nc
  ncrename -v ${arr_var1[i]},All ${arr_var1[i]}temp.nc
done

rm tmp1.nc tmp2.nc tmp3.nc ALL.nc
ncbo --op_typ=add ${arr_var1[0]}temp.nc ${arr_var1[1]}temp.nc tmp1.nc
ncbo --op_typ=add ${arr_var1[2]}temp.nc ${arr_var1[3]}temp.nc tmp2.nc
ncbo --op_typ=add ${arr_var1[4]}temp.nc tmp1.nc tmp3.nc
ncbo --op_typ=add tmp3.nc tmp2.nc ALL.nc
rm ${arr_var1[0]}temp.nc ${arr_var1[1]}temp.nc ${arr_var1[2]}temp.nc ${arr_var1[3]}temp.nc ${arr_var1[4]}temp.nc
rm tmp1.nc tmp3.nc tmp2.nc

##ncks -A QCLOUD.nc QRAIN.nc QICE.nc QSNOW.nc  QGRAUP.nc ALL.nc
ncks -A QCLOUD.nc LATLON.nc
ncks -A QRAIN.nc LATLON.nc
ncks -A QICE.nc LATLON.nc
ncks -A QSNOW.nc LATLON.nc
ncks -A QGRAUP.nc LATLON.nc
#ncks -A ALL.nc LATLON.nc
ncks -A Time.nc LATLON.nc
cp LATLON.nc wrfout.nc
