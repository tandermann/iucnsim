#library(devtools)
#install_github("tobiashofmann88/iucnsim")
library(iucnsim)
library(reticulate)
library(rredlist)
reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
#reticulate::source_python("../iucn_extinction_simulator/iucn_sim/iucn_sim.py")

# load the tutorial data, a list of species form the order Carnivora.
data('carnivora') # will be saved as species_list

reference_group = "Mammalia"
reference_rank = "class"
iucn_key='insert_your_iucn_key_here' # this tutorial uses precompiled IUCN data, but you will need your own iucn key when running different datasets


#______________________GET IUCN DATA_________________________________
outdir = 'data/iucn_sim/iucn_data'
# get iucn history of reference group
iucn_history_file = get_iucn_history(reference_group=reference_group,
                                     reference_rank=reference_rank,
                                     iucn_key=iucn_key,
                                     outdir=outdir)

counted_status_transition_events = evaluate_iucn_history(iucn_history_file)

# get most recent status for each taxon in target species list
extant_taxa_current_status = get_most_recent_status_target_species(species_list=species_list,
                                                                   iucn_history_file=iucn_history_file,
                                                                   iucn_key=iucn_key,
                                                                   outdir=outdir)

#invalid_status_taxa = get_invalid_statuses(extant_taxa_current_status)


# get info about possibly extinct taxa
possibly_extinct_taxa = get_possibly_extinct_iucn_info(iucn_history_file,
                                                       outdir=outdir)


#______________________ESTIMATE TRANSITION RATES___________________________
outdir = 'data/iucn_sim/transition_rates'
transition_rates_out = estimate_transition_rates(extant_taxa_current_status,
                                                  iucn_history_file,
                                                  outdir,
                                                  extinction_probs_mode=0,
                                                  possibly_extinct_list=possibly_extinct_taxa)


#______________________SIMULATE FUTURE EXTINCTIONS___________________________
outdir = 'data/iucn_sim/future_simulations'
sim_years = 50
future_sim_output = run_future_sim(transition_rates_out,
                                  outdir,
                                  n_years=sim_years,
                                  n_sim=100)
# extract the different output items
extinction_times = future_sim_output[[1]]
future_div_min_max = future_sim_output[[2]]
status_through_time_trajectories = future_sim_output[[3]]


#_________ESTIMATE EXTINCTION RATES FROM FUTURE SIMULATIONS__________________
outdir = 'data/iucn_sim/extinction_rates'
ext_rates = estimate_extinction_rates(extinction_times,
                                      sim_years,
                                      outdir,
                                      load_from_file=FALSE)

