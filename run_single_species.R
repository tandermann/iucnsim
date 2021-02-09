library(iucnsim)
library(reticulate)
library(rredlist)
reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")

# define input species
species_list = data.frame('Paraclaravis geoffroyi')

# define reference group
reference_group = "Aves"
reference_rank = "class"

outdir = 'paraclaravis_sim/iucn_data'
# get iucn history of reference group
iucn_history_file = get_iucn_history(reference_group=reference_group,
                                     reference_rank=reference_rank,
                                     outdir=outdir)

# get most current IUCN status
extant_taxa_current_status = get_most_recent_status_target_species(species_list=species_list,
                                                                   iucn_history_file=iucn_history_file,
                                                                   outdir=outdir)

# add generation length data from IUCN
extant_taxa_current_status['2'] = 4.6

# estimate status transition rates
outdir = 'paraclaravis_sim/transition_rates'
transition_rates_out = estimate_transition_rates(extant_taxa_current_status,
                                                 iucn_history_file,
                                                 outdir,
                                                 extinction_probs_mode=0)

# simulate future
outdir = 'paraclaravis_sim/future_simulations'
sim_years = 100
future_sim_output = run_future_sim(transition_rates_out,
                                   outdir,
                                   n_years=sim_years,
                                   plot_diversity_trajectory=FALSE,
                                   plot_status_trajectories=FALSE,
                                   plot_status_piechart=FALSE)

# extract the different output items
extinction_times = future_sim_output[[1]]
future_div_min_max = future_sim_output[[2]]
status_through_time_trajectories = future_sim_output[[3]]

# estimate extinction rates from future simulations
outdir = 'paraclaravis_sim/extinction_rates'
ext_rates = estimate_extinction_rates(extinction_times,
                                      sim_years,
                                      outdir,
                                      plot_posterior=TRUE)
