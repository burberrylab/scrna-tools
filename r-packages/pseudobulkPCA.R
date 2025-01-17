pseudobulkPCA <- function(seurat_obj, assays, group.by, npcs, ident, sort=TRUE, pt.size=3, savePCs=FALSE, file_prefix=NULL){
	require(Seurat)
	bulk_obj <- AggregateExpression(object=seurat_obj, assays=assays, return.seurat = T, group.by=group.by) %>% NormalizeData() %>% FindVariableFeatures() %>% ScaleData() %>% RunPCA(npcs=npcs)
	if(sort){
		levels <- sort(unique(bulk_obj@meta.data[[ident]]))
		bulk_obj@meta.data[[ident]] <- factor(bulk_obj@meta.data[[ident]], levels=levels)
	}
	if(savePCs){
		write.csv(Embeddings(bulk_obj, reduction = "pca"), file=paste0(file_prefix,"_embeddings.csv"))
		write.csv(Loadings(bulk_obj, reduction = "pca"), file=paste0(file_prefix,"_loadings.csv"))

	}
	Idents(bulk_obj) <- ident
	return(DimPlot(object=bulk_obj, pt.size=pt.size))
}
