#$ -pe local 10
#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

data_name="hca_bonemarrow"
B_name="1"

#Rscript --slave ../02-normalization.R --args $data_name $B_name
#Rscript --slave ../03-dim-reduction.R --args $data_name $B_name
Rscript --slave ../03_1-pca_only.R --args $data_name $B_name
#Rscript --slave ../04-cluster_find_k.R --args $data_name $B_name