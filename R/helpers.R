#' IUCNN functions to estimate missing statuses using neural network
#' @export
#' @import reticulate


get_invalid_statuses = function(current_status_df){
  A = current_status_df[2][[1]]
  valid_statuses = c('LC','NT','VU','EN','CR')
  invalid_status_df = current_status_df[which(!A %in% valid_statuses),]
  return(invalid_status_df)
}
