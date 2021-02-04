#' iucnsim functions
#' @export
#' @import reticulate
#' @import rredlist
#'
reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")


#' Estimate status transition rates
#' @export
#' @import reticulate

estimate_transition_rates = function(extant_taxa_current_status,
                                     iucn_history_file,
                                     outdir,
                                     possibly_extinct_list,
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
  reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
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

#' Simulate future extinctions
#' @export
#' @import reticulate

run_future_sim = function(simulation_input_data,
                          outdir,
                          n_years=100,
                          n_sim=10000,
                          status_change=TRUE,
                          conservation_increase_factor=1,
                          threat_increase_factor=1,
                          model_unknown_as_lc=FALSE,
                          until_n_taxa_extinct=0,
                          plot_diversity_trajectory=TRUE,
                          plot_status_trajectories=TRUE,
                          plot_histograms=FALSE,
                          plot_status_piechart=TRUE,
                          seed=NULL,
                          load_from_file=FALSE
){

  # source python function
  reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
  simulation_output = run_sim(simulation_input_data,
                              outdir,
                              n_years=n_years,
                              n_sim=n_sim,
                              status_change=status_change,
                              conservation_increase_factor=conservation_increase_factor,
                              threat_increase_factor=threat_increase_factor,
                              model_unknown_as_lc=model_unknown_as_lc,
                              until_n_taxa_extinct=until_n_taxa_extinct,
                              plot_diversity_trajectory=plot_diversity_trajectory,
                              plot_status_trajectories=plot_status_trajectories,
                              plot_histograms=plot_histograms,
                              plot_status_piechart=plot_status_piechart,
                              seed=seed,
                              load_from_file=load_from_file)

  #py_list_attributes(simulation_output)

  extinction_times = reticulate::py_get_attr(simulation_output,'_extinction_times')
  future_div_min_max = reticulate::py_get_attr(simulation_output,'_future_div_mean_min_max')
  status_through_time_trajectories = reticulate::py_get_attr(simulation_output,'_status_through_time_mean')

  # convert the extinction times into an r-friendly format
  extinction_times_r_format = reticulate::py_to_r(extinction_times)

  return(list(extinction_times_r_format,
              future_div_min_max,
              status_through_time_trajectories))
}
