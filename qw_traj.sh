#!/bin/sh

#files need: .energies
#            .traj 

#  argument 1 = charactrers before .traj #This will also be prefix of energies file
#  argument 2 = character after traj.   #this is the processer number first processor you want to analyse
#  argument 3 = last processor number you want to analyse

ns_analyse $1.energies -M 0.1 -n 500 -D 5 > pf
echo 'Energy:    Volume:    q4:      w4:    q6:    w6:  iteration:   Temp:  U:' > $1-$2-$3.qw46HV

for iter in $(seq $2 $3)
do	
	echo 'Processor number:'  $iter
	get_qw atfile_in=$1.traj.$iter.extxyz r_cut=3 l=4 calc_QWave=T  > $1.traj.$iter.qw4
	get_qw atfile_in=$1.traj.$iter.extxyz r_cut=3 l=6 calc_QWave=T  > $1.traj.$iter.qw6
	
	
	tail -n+12 $1.traj.$iter.qw4 | head -n-3 > $1.qw4_temp
	tail -n+12 $1.traj.$iter.qw6 | head -n-3 > $1.qw6_temp
	
	# grep the energies, ke,  volumes and iteration numbers from the traj files in neat columns and creat temporary files:
	grep -o ns_energy=.[[:digit:]]*\.[[:digit:]]* $1.traj.$iter.extxyz | sed "s/ns_energy=//g" >> $1.ener_temp
	grep -o volume=.[[:digit:]]*\.[[:digit:]]* $1.traj.$iter.extxyz | sed "s/volume=//g" >> $1.vol_temp
	grep -o iter=.[[:digit:]]*\.[[:digit:]]* $1.traj.$iter.extxyz | sed "s/iter=//g" >> $1.iter_temp
	grep -o ns_KE=.[[:digit:]]*\.[[:digit:]]* $1.traj.$iter.extxyz | sed "s/ns_KE=//g" >> $1.ke_temp
	
	
	H_T_extrapolate.py $1.ener_temp $1.ke_temp
	
	#grep the energies, volume, Q and W data from the two files and create a summary result file, neatly arranging them by columns
	pr -m -t -s $1.ener_temp $1.vol_temp $1.qw4_temp $1.qw6_temp $1.iter_temp temp.temp U.temp| awk '{print $1,$2,$3,$4,$5,$6,$7,$8, $9 }' >> $1-$2-$3.qw46HV
	
	# remove the temporary files
	rm $1.ener_temp
	rm $1.vol_temp
	rm $1.qw4_temp
	rm $1.qw6_temp
	rm $1.iter_temp
	rm temp.temp
	rm $1.ke_temp
	rm U.temp
done

mkdir qw46

mv *.qw4 qw46
mv *.qw6 qw46
mv *.idx qw46
