# requires category to be in the order desired
# # if category needs to be reordered, use format below:
# # # > catVec <- unique(obj$category)
# # # > catVec <- c(catVec[x], catVec[y], catVec[z]) #reorder as desired
# # # > obj$category <- factor(obj$category, levels = catVec)

# Inputs: 
#  seurat_obj: 		Seurat object
#  library_name: 	metadata column name for which sample each cell came from
#  cluster_name: 	metadata column name for which cluster (or any other grouping) a cell is in
#  group_name:		metadata column name for categories to split libraries by
#  title:		title for graph
#  calculate:		if true, will calculate ANOVA for differences in distribution
#  filename:		filename for calculation to write ANOVA to


propellerGraph <- function(seurat_obj, library_name, cluster_name, group_name, title, calculate = FALSE, filename=NULL){

	require(speckle, ggplot2)

	meta.df <- data.frame(seurat_obj[[library_name]], seurat_obj[[cluster_name]], seurat_obj[[group_name]])
	names(meta.df) <- c("library", "cluster", "group")
	if(calculate){
		write.csv(propeller(clusters = meta.df$cluster, sample = meta.df$library, group = meta.df$group), file = filename)
	}
	return(ggplot(meta.df, aes(x=library, fill = cluster)) + geom_bar() + facet_wrap(~ group, scales="free") + theme_bw() + ggtitle(title))
 
}


