# Perform Seurat DGEs and output to format usable by UpSetR, which it will write to disk.

# Inputs:
#   seurat_obj:     Seurat object
#   features:       vector of characters: gene names to look for. Defaults to all genes in Seurat object
#   group.by:       string: name of metadata column to group by for DGEs(e.g. genotype, treatment group, etc.)
#   split.by:       string: name of metadata column to split by before DGEs (e.g. cluster, cell type, sample identity, etc.). Set to "all" to skip splitting object (i.e. use all cells)
#   group.by.vars:  vector of strings: list of unique values in group.by column to use for pairwise comparison. defaults to unique(seurat_obj[[group.by]]).
#   split.by.vars:  vector of strings: list of unique values in split.by column to break object up by. defaults to unique(seurat_obj[[split.by]]).


DGEtoUpSet <- function(seurat_obj, features = NULL, group.by, split.by, group.by.vars = NULL, split.by.vars = NULL, slot = "data", test.use = "wilcox", split.by.direction = TRUE, saveCSV = TRUE, csv.filename = NULL, saveDGEs = FALSE, rds.filename = NULL){
  
  if(identical(split.by, "all")){
    splitList <- list(all = seurat_obj)
  }
  else{
    splitList <- SplitObject(seurat_obj, split.by)
    if(!is.null(split.by.vars)){
      keep.indices <- which(names(splitList) %in% split.by.vars)
      splitList <- splitList[keep.indices]
    }
  }
  
  nTypes <- length(splitList)

  masterDGEList <- list()
  nTotalDGEs <- 0
  
  if(is.null(group.by.vars)){
    group.by.vars <- unique(seurat_obj[[group.by]])[,1]
  }
  print(group.by.vars)
  comparisons <- as.matrix(combn(group.by.vars, m = 2))
  nComparisons <- ncol(comparisons)
  
  for(i in 1:nTypes){
    current_obj <- splitList[[i]]
    current_obj_name <- names(splitList)[i]
    
    Idents(current_obj) <- group.by
    currentList <- list()
    
    for(j in 1:nComparisons){
      group1 <- comparisons[1,j]
      group2 <- comparisons[2,j]
      
      currentList[[j]] <- FindMarkers(object = current_obj, ident.1 = group1, ident.2 = group2, slot = slot, test.use = test.use)
      names(currentList)[j] <- paste0(group1, "_vs_", group2)
      nTotalDGEs = nTotalDGEs + 1
    }
    masterDGEList[[i]] <- currentList
    names(masterDGEList)[i] <- current_obj_name
  }
  
  # masterDGEList now contains all DGEs in a nested structure. We will increment through these, pasting the sublevel name after the toplevel name.

  if(is.null(features)){
    features <- rownames(seurat_obj)
  }
  nFeatures <- length(features)

  # create new data frame for the set inclusion data
  results <- data.frame(row.names = features)
  
  # Case 1: we split the DGEs by direction (enrichment vs depression)
  if(split.by.direction){
    for(j in 1:nComparisons){
      for(i in 1:nTypes){
        prev_idx = 2*i*j
        current_DGE <- masterDGEList[[i]][[j]]
        current_type <- names(masterDGEList)[i]
        current_comparison <- names(masterDGEList[[i]])[j]
        
        upList <- rownames(subset(current_DGE, avg_log2FC > 0 & p_val_adj < 0.05))
        upCol <- rep(0, times = nFeatures)
        upCol[which(features %in% upList)] <- 1
        upColName <- paste0(current_type, "_", current_comparison, "_up_in_first")
        results$temp <- upCol
        results[,upColName] <- results$temp
        
        downList <- rownames(subset(current_DGE, avg_log2FC < 0 & p_val_adj < 0.05))
        downCol <- rep(0, times = nFeatures)
        downCol[which(features %in% downList)] <- 1
        downColName <- paste0(current_type, "_", current_comparison, "_down_in_first")
        results[,downColName] <- downCol
        
      }
    }
  }
  
  else {
    for(i in 1:nTypes){
      for(j in 1:nComparisons){
        prev_idx = i*j
        current_DGE <- masterDGEList[[i]][[j]]
        current_type <- names(masterDGEList)[i]
        current_comparison <- names(masterDGEList[[i]])[j]
        
        degList <- rownames(subset(current_DGE, p_val_adj < 0.05))
        degCol <- rep(0, times = nFeatures)
        degCol[which(features %in% dgeList)] <- 1
        degColName <- paste0(current_type, "_", current_comparison, "_total_DEGs")
        results[[degColName]] <- degCol
      }
    }
  }
  
  # results now contains all of the set inclusion data for the genes and DGEs.
  
  if(saveDGEs){
    if(is.null(rds.filename) | length(rds.filename) <= 0){
      rds.filename = "masterDGElist.rds"
    }
    saveRDS(masterDGEList, file = rds.filename)
    print(paste("DGEs saved to disk as", rds.filename))
  }
  
  if(saveCSV){
    if(is.null(csv.filename) | length(csv.filename) <= 0){
      csv.filename = "DGE_set_inclusions.csv"
    }
    write.csv(results, file = csv.filename, row.names = TRUE, col.names = TRUE)
    print(paste("Results csv saved to disk as", csv.filename))
  }
  
  
  return(results)
}
