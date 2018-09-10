#!/bin/sh
set -xa

export scripts=$1
export exec=$2
export exefile=$3
export datadir=$4
export tmpdir=$5
export ptype=$6

# export scripts=/u/Xiujuan.Su/home/gsiqc3/regional_scripts 
# export exec=/u/Xiujuan.Su/home/gsiqc3/exec
# export exefile=make_list_time.x 
## export datadir=/u/Xiujuan.Su/nbns/bufrstas_regional
# export datadir=/u/Xiujuan.Su/nbns/bufrstas_regional_20110405
# export datadir2=/u/Xiujuan.Su/nbns/select_reg_20110405
# export savedir=/u/Xiujuan.Su/home/gsiqc3/regional/data/201104-05
 export NDATE=/nwprod/util/exec/ndate
export SUB=/gpfs/td1/emc/global/save/emc.glopara/svn/gfs/trunk/para/bin/sub_wcoss


 mkdir -p $tmpdir
 cd $tmpdir
 rm -f *

 cp $exec/$exefile ./$exefile

cp $datadir/*rej*_final ./.
rm -f *sp*final
for file in uv* 
do
f1=uv
f2=`echo ${file} | cut -c3-5`
f3=_rej_list_final
f22=` expr $f2 - 100`
nfile=${f1}${f22}${f3}
echo $file
echo $nfile
mv $file $nfile
done


for type in $ptype
do
for ddtype in ps t q uv
do
if [ -s ${ddtype}${type}_rej_list_final ]; then
mv ${ddtype}${type}_rej_list_final ./${ddtype}${type}_rej_list
eval filexist${ddtype}=.true.
else
eval filexist${ddtype}=.false.
fi
stype=${ddtype}${type}
if [ "${stype}" = 'q120' -o "${stype}" = 't120' -o "${stype}" = 'uv120' -o \
    "${stype}" = 'uv121' -o "${stype}" = 'uv123' -o "${stype}" = 'uv124'   \
    -o "${stype}" = 'uv128' -o "${stype}" = 'uv129' ]; then
eval itype${ddtype}=1
else
eval itype${ddtype}=0
fi

done

cat <<EOF >input
      &input
      type=${type},
      itype(1)=${itypeps},itype(2)=${itypet},itype(3)=${itypeq},itype(4)=${itypeuv},
      filexist(1)=${filexistps},filexist(2)=${filexistt},filexist(3)=${filexistq},filexist(4)=${filexistuv},
/
EOF



./$exefile <input>stdout 2>&1

 mv stdout ${type}_stdout
 

done    ## type

for file in uv*
do
f1=`echo ${file} | cut -c7-12`
if [ "${f1}" = 'emcrej' ]; then
f2=`echo ${file} | cut -c3-5`
f3=_emcrej_list
ff=uv
f22=` expr $f2 + 100`
nfile=${ff}${f22}${f3}
echo $file
echo $nfile
mv $file $nfile
fi
done





exit
