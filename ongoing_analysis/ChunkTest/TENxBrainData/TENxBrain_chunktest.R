options(warn=-1)

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

size <- commandArgs(trailingOnly=T)[2]
chunk <- commandArgs(trailingOnly=T)[3]
batch <- as.numeric(commandArgs(trailingOnly=T)[4])
mode <- commandArgs(trailingOnly=T)[5]
calc_lab <- as.logical(commandArgs(trailingOnly=T)[6])
cent_file_name <- commandArgs(trailingOnly=T)[7]
choice <- commandArgs(trailingOnly=T)[8]
method <- commandArgs(trailingOnly=T)[9]
run_id <- commandArgs(trailingOnly=T)[10]
k <- 15

time_file <- paste0("time_", run_id, ".csv")
mem_file <- paste0("mem_", run_id, ".csv")

if (mode == "time"){
  if(!file.exists(here("ongoing_analysis/ChunkTest/TENxBrainData/Output", time_file))){
    profile_table <- data.frame(matrix(vector(), 0, 11, 
                                     dimnames=list(c(), c("observations", "genes",
                                                          "abs batch size",
                                                          "time1", "time2","time3","geometry","dimension_1","dimension_2","choice","label"))),
                              stringsAsFactors=F)
    write.table(profile_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", time_file), 
              sep = ",", col.names = TRUE)
  }
  
  
  if (method == "hdf5"){
    if (choice == "full"){
      time.start1 <- proc.time()
      tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                                paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
      invisible(mbkmeans(counts(tenx), clusters=k, batch_size = 500, 
                         num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=TRUE))
      time.end1 <- proc.time()
      time1 <- time.end1 - time.start1
      
      temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], 
                               abs_batch_size = 500,
                               #batch_size = batch, 
                               #abs_batch_size =  round(dim(counts(tenx))[2]*batch, -1), 
                               time1 = time1[3], time2 = NA, time3 = NA, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                               dimension_2 = seed(counts(tenx))@chunkdim[2], choice = "full", label = paste0(chunk, "_", method))
      write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", time_file), 
                  sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
}

    
if (mode == "mem"){
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0("TENxBrain_", size, "_", chunk, "_", now, "_", batch,".out")
  
  if(!file.exists(here("main/case_studies/output/Memory_output/chunk_test"))) {
    dir.create(here("main/case_studies/output/Memory_output/chunk_test"), recursive = TRUE)}
  
  if(!file.exists(here("ongoing_analysis/ChunkTest/TENxBrainData/Output", mem_file))){
    profile_table <- data.frame(matrix(vector(), 0, 9, 
                                       dimnames=list(c(), c("observations", "genes",
                                                            "abs batch size",
                                                            "memory","geometry","dimension_1","dimension_2","choice","label"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", mem_file), 
                sep = ",", col.names = TRUE)
  }
  

  if (method == "hdf5"){
    if (choice == "full"){
      Rprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), append = FALSE, memory.profiling = TRUE)
      tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                                paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
      invisible(mbkmeans(counts(tenx), clusters=k, batch_size = 500, 
                         num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=TRUE))
      Rprof(NULL)
      
      profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), chunksize = -1L, 
                              memory = "tseries", diff = FALSE)
      max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
      
      temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1],
                               abs_batch_size = 500,
                               #batch_size = batch, 
                               #abs_batch_size =  round(dim(counts(tenx))[2]*batch, -1), 
                               mem = max_mem, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                               dimension_2 = seed(counts(tenx))@chunkdim[2], choice = "full", label=paste0(chunk, "_", method))
      write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", mem_file), 
                  sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
}

