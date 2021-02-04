library(tidyverse)
library(IUCNN)
library(reticulate)
source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
#source_python('../iucn_extinction_simulator/iucn_sim/iucn_sim.py')

#load example data 
data("training_occ") #geographic occurrences of species with IUCN assessment
data("training_labels")# the corresponding IUCN assessments
data("prediction_occ") #occurrences from Not Evaluated species to prdict

# Training
## Generate features
geo <- geo_features(training_occ) #geographic
cli <- clim_features(training_occ) #climate
bme <- biome_features(training_occ) #biomes

features <- geo %>% 
  left_join(cli) %>% 
  left_join(bme)

# Prepare training labels
labels_train <- prepare_labels(training_labels)

# train the model
train_iucnn(x = features,
            labels = labels_train)

#Prediction
## Generate features
geo <- geo_features(prediction_occ)
cli <- clim_features(prediction_occ)
bme <- biome_features(prediction_occ)

features_predict <- geo %>% 
  left_join(cli) %>% 
  left_join(bme)

labels = predict_iucnn(x = features_predict,
                       model_dir = "iuc_nn_model")

iucn_labels = translate_numeric_labels(labels)

outdir = 'data/iucn_sim/iucn_data'
reference_group = 'Asparagales'
reference_rank = 'order'
iucn_key = '01524b67f4972521acd1ded2d8b3858e7fedc7da5fd75b8bb2c5456ea18b01ba'

# write R scripts and execute to extract IUCN history of reference group
write_r_scripts(outdir)
iucn_history_file = get_iucn_history(outdir,reference_group,reference_rank,iucn_key)

# Estimate status and extinction transition rates_________________________
outdir = 'data/iucn_sim/transition_rates'
transition_rates = transition_rates(iucn_labels,
                                    iucn_history_file,
                                    outdir,
                                    extinction_probs_mode=0,
                                    possibly_extinct_list=0,
                                    species_specific_regression=FALSE,
                                    rate_samples=100,
                                    n_gen=100000,
                                    burnin=1000,
                                    seed=NULL,
                                    load_from_file=FALSE)



# Run future simulations__________________________________________________
simulation_input_data = py_get_attr(transition_rates,'_simulation_input_data') # You will likely encounter the error: "Error in .Call(`_reticulate_py_str_impl`, x) : reached elapsed time limit", but it doens't appear to affect the operation
outdir = 'data/iucn_sim/future_sim'
simulation_output = run_sim(simulation_input_data,
                            outdir,
                            n_years=100,
                            n_sim=10000,
                            status_change=1,
                            conservation_increase_factor=1,
                            threat_increase_factor=1,
                            model_unknown_as_lc=0,
                            until_n_taxa_extinct=0,
                            extinction_rates=1,
                            n_gen=100000,
                            burnin=1000,
                            plot_diversity_trajectory=1,
                            plot_status_trajectories=1,
                            plot_histograms=0,
                            plot_posterior=0,
                            plot_status_piechart=1,
                            seed=NULL,
                            load_from_file = FALSE)


py_list_attributes(simulation_output)
py_get_attr(simulation_output,'_extinction_probs')


