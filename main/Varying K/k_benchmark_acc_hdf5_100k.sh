#$-pe local 10
#$ -l mem_free=8G,h_vmem=8G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="acc"
method="hdf5"
size="small"
B=10
B_name="10"
cores=10
nC=(100000)
nG=(1000)
batch=(0.01 0.1)
center=(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
sim_center=15
initializer="random"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${mode}_${method}_${nC}_${batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${mode}_${method}_${nC}_${batch}_${B_name}"

init=TRUE
Rscript --slave ../benchmark_varying_k.R \
--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark_varying_k.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center
			done
		done
	done
done