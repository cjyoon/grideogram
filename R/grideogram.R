color_coding = c('gneg'=gray(1), 'gpos25' = gray(0.75), 'gpos50'  = gray(0.5), 'gpos75'=gray(0.25), 'gpos100'=gray(0), 'gvar'='#87CEFA', 'acen1'='#AA3C28', 'acen2'='#AA3C28', 'stalk'='#6D7FA3')
is_centromere = c('gneg'=0, 'gpos25' = 0, 'gpos50'  = 0, 'gpos75'=0, 'gpos100'=0, 'gvar'=0, 'acen1'=1, 'acen2'=2, 'stalk'=0)
scale_conversion  <- function(pos, min_pos, max_pos){
  return (pos-min_pos)/max_pos
}

inverse_is_centro <- function(centromere_status){
  if(centromere_status==1){
    return(2)
  }else if(centromere_status==2){
    return(1)
  }else{
    return(centromere_status)
  }
}
inverse_is_centro_vec <- Vectorize(inverse_is_centro)


#' Draw ideogram of a chromosome
#'
#' @param ideo_chrom chromosome with chr[0-9XY]+ to draw
#' @param ideo_start starting position of the fragment for drawing ideogram
#' @param ideo_end ending position of the fragment for drawing ideogram
#' @param ref Reference assembly build. Either grch37 or grch38. Defautl: grch37
#' @param scale_factor size conversion factor. scale factor of 300M (default) will draw 300M in the full width of the grid
#' @param xpos, ypos (x, y) coordinate position in 'npc' unit
#' @param height height of the ideogram in 'npc' unit
#' @param label add label to the contig
#' @param adjust if set to TRUE, will left align the fragment to \code{xpos}
#' @param inv if set to TRUE will draw inverted fragment
#' @param label_x_pos align label to either 'center', 'left', or 'right' side of the ideogram.
#' @return grobs of ideogram object with label
#' @export
#' @examples
#' draw_ideogram('chr1', 120000000, 200000000, ref='grch37', xpos=0.1, ypos=0.3, height=0.1, adjust=F, inv=T, label_x_pos='left')
#' draw_ideogram('chr22')
#' draw_ideogram('chr10', 120000000, 200000000, ref='grch38', xpos=0.1, ypos=0.3, height=0.1, adjust=F, inv=T, label_x_pos='left')
draw_ideogram <- function(ideo_chrom, ideo_start='', ideo_end='', ref='grch37', scale_factor=300000000, xpos=0, ypos=0, height = 0.1, label=NA, adjust=T, inv=F, label_x_pos='center'){

  if(is.na(scale_factor)){
    scale_factor = ideo_end-ideo_start
  }


  if(is.na(ideo_start) | ideo_start==''){
    ideo_start=1
  }

  if(ref=='grch37'){
    cyto_df = grch37
    chrom_max =grch37_chrom_size[[ideo_chrom]]
  }else if(ref=='grch38'){
    cyto_df = grch38
    chrom_max = grch38_chrom_size[[ideo_chrom]]
  }else{
    stop('Reference assembly not supported')
  }

  if(is.na(ideo_end) | ideo_end==''){
    ideo_end = chrom_max
  }

  print(cyto_df)
  # cyto_df_roi = cyto_df %>% filter(chromosome==ideo_chrom) %>% filter(start >= ideo_start) %>% filter(end <= ideo_end)
  cyto_df_roi = cyto_df %>% dplyr::filter(chromosome==ideo_chrom) %>% dplyr::filter(start >= ideo_start) %>% dplyr::filter(end <= ideo_end)
  if(dim(cyto_df_roi)[1]==0){
    cyto_df_roi = cyto_df%>% dplyr::filter(chromosome==ideo_chrom) %>% dplyr::filter(start < ideo_start & end > ideo_start)  }
  # cut off the first column with ideo_start
  # print(cyto_df)
  cyto_df_roi[1,'start'] = ideo_start

  # cut off the last column with ideo_end
  cyto_df_roi[dim(cyto_df_roi)[1], 'end'] = ideo_end
  x_adjust = min(cyto_df_roi$start)
  if(adjust==T){
    cyto_df_roi = cyto_df_roi %>% dplyr::mutate(start = start-x_adjust) %>% dplyr::mutate(end = end - x_adjust)
  }



  if(inv==T){
    rotate_start = max(cyto_df_roi$end) - cyto_df_roi$end
    rotate_end = max(cyto_df_roi$end) - cyto_df_roi$start
    cyto_df_roi$start = rotate_start
    cyto_df_roi$end = rotate_end
  }
  cyto_df_roi$color = sapply(cyto_df_roi$stain, function(x){color_coding[[x]]})
  cyto_df_roi$start_grid = sapply(cyto_df_roi$start, function(x){ (x)/scale_factor})
  cyto_df_roi$end_grid = sapply(cyto_df_roi$end, function(x){ (x)/scale_factor})
  cyto_df_roi$is_centro = sapply(cyto_df_roi$stain, function(x){is_centromere[[x]]})

  if(inv==T){
    cyto_df_roi$is_centro = inverse_is_centro_vec(cyto_df_roi$is_centro)
  }

  if(label_x_pos=='center'){
    label_x_pos = (min(cyto_df_roi$start_grid) + max(cyto_df_roi$end_grid))/2 + xpos
    just_vector = c('center', 'top')
  }else if(label_x_pos=='left'){
    label_x_pos = min(cyto_df_roi$start_grid) + xpos
    just_vector = c('left', 'top')
  }else if(label_x_pos=='right'){
    label_x_pos =max(cyto_df_roi$end_grid) + xpos
    just_vector = c('right', 'top')
  }else{
    label_x_pos=label_x_pos
    just_vector = c('center', 'bottom')
  }

  for(i in 1:dim(cyto_df_roi)[1]){
    cyto_grob = draw_band(cyto_df_roi$start_grid[i], cyto_df_roi$end_grid[i], xpos, ypos, height, color=cyto_df_roi$color[i], is_centro=cyto_df_roi$is_centro[i])
    grid.draw(cyto_grob)
  }
  if(!is.na(label)){
    if(inv==T){
      grid.text(label = label, x = label_x_pos, y = unit(ypos, 'npc') + unit(height, 'npc'), rot = 180, just=just_vector)
    }else{
      grid.text(label = label, x = label_x_pos, y = unit(ypos, 'npc'), just=just_vector)
    }
  }
}


draw_band <- function(grid_start, grid_end, xpos, ypos, height, color, is_centro){

  if(is_centro==0){
    p <- rectGrob(x=xpos + grid_start, y=ypos, width = (grid_end-grid_start), height=height, gp=gpar(fill=color, col='black', lwd=0.5), just=c('left', 'bottom'))
  }else if(is_centro==1){
    p <- polygonGrob(x=c(xpos + grid_start, xpos + grid_end, xpos + grid_start), y=c(ypos, ypos + 0.5*height, ypos + height),  gp=gpar(fill=color, col='black', lwd=0.5))

  }else if(is_centro==2){
    p <- polygonGrob(x=c(xpos+ grid_start, xpos+grid_end, xpos+ grid_end), y=c(ypos + 0.5*height, ypos + height, ypos),  gp=gpar(fill=color, col='black', lwd=0.5))
  }else{
    p <- polygonGrob(x=0, y=0)
  }
  grid.draw(p)
  return(p)
}


