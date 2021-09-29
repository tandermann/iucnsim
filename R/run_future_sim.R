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
                          load_from_file=FALSE,
                          save_future_status_array=FALSE
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
                              load_from_file=load_from_file,
                              save_future_status_array=save_future_status_array)

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
