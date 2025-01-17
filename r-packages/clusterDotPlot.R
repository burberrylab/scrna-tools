clusterDotPlot <- function(seurat_obj, ident, n_features, save_full=FALSE, filename=NULL){
	require(Seurat, magrittr)
	Idents(seurat_obj) <- ident
	seurat_obj.ident.markers <- FindAllMarkers(seurat_obj)
	if(save_full){
		write.csv(seurat_obj.ident.markers, file = filename)
	}
	groups = unique(seurat_obj@meta.data[[ident]]) %>% sort()
	clust.feats <- c()
	for(x in groups){
		x_feats <- dplyr::filter(seurat_obj.ident.markers, cluster == x)[1:n_features,'gene']
		clust.feats <- c(clust.feats, x_feats)
	}
	clust.feats <- unique(clust.feats)
	return(DotPlot(seurat_obj, features = clust.feats))
}
