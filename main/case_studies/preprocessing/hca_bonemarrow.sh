#$-pe local 10
#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

R -e "rmarkdown::render('hca_bonemarrow.Rmd')"