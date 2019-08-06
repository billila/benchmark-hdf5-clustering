#$ -l mem_free=10G,h_vmem=10G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

nC=(1000 5000 25000 75000 100000 175000 250000)
nG=(1000)
sim_center=3
data_path="/fastscratch/myscratch/rliu/Aug_data"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for i in {1..2}; do
			Rscript simulation.R --args $c $g $sim_center $data_path $i
		done
	done
done