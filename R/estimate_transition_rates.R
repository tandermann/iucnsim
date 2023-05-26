#' Estimate status transition rates
#' @export
#' @import reticulate

estimate_transition_rates = function(extant_taxa_current_status,
                                     iucn_history_file,
                                     outdir,
                                     possibly_extinct_list=list(),
                                     extinction_probs_mode=0,
                                     species_specific_regression=FALSE,
                                     rate_samples=100,
                                     n_gen=100000,
                                     burnin=1000,
                                     seed=NULL,
                                     load_from_file=FALSE,
                                     return_object=TRUE
                                     ){

  # source python function
  reticulate::source_python("https://raw.githubusercontent.com/tandermann/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
  transition_rates_obj = transition_rates(extant_taxa_current_status,
                                          iucn_history_file,
                                          outdir,
                                          extinction_probs_mode=extinction_probs_mode,
                                          possibly_extinct_list=possibly_extinct_list,
                                          species_specific_regression=species_specific_regression,
                                          rate_samples=rate_samples,
                                          n_gen=n_gen,
                                          burnin=burnin,
                                          seed=seed,
                                          load_from_file=load_from_file)

  if(return_object==TRUE){
    return(py_get_attr(transition_rates_obj,'_simulation_input_data'))
  }else{
    return(py_get_attr(transition_rates_obj,'_simdata_outfile'))
  }
}
