# prep_data
# library(tidyverse)

# grch37 = read_delim('~/Documents/cjyoon/scripts/grideogram/inst/extdata/grch37_cytoBandIdeo.txt', delim='\t', col_names=c('chromosome', 'start', 'end', 'band', 'stain'))
# grch38 = read_delim('~/Documents/cjyoon/scripts/grideogram/inst/extdata/grch38_cytoBandIdeo.txt', delim='\t', col_names=c('chromosome', 'start', 'end', 'band', 'stain'))
# grch37_chrom_size_df = read_delim('~/Documents/cjyoon/reference/GRCh37/human_g1k_v37.fa.fai', delim='\t', col_names = c('chrom', 'size', 'a', 'b', 'c'))
# grch37_chrom_size_df = grch37_chrom_size_df %>% mutate(chrom=paste0('chr', chrom))
# grch37_chrom_size = setNames(grch37_chrom_size_df$size, grch37_chrom_size_df$chrom)
#
# grch38_chrom_size_df = read_delim('~/Documents/cjyoon/reference/GRCh38/grch38.fa.fai', delim='\t', col_names = c('chrom', 'size', 'a', 'b', 'c'))
# grch38_chrom_size =  setNames(grch38_chrom_size_df$size, grch38_chrom_size_df$chrom)
# usethis::use_data(grch37, grch38, grch37_chrom_size, grch38_chrom_size, internal=T, overwrite=T)
