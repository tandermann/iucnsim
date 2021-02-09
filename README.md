# Welcome to the `iucnsim` R-package

[![Travis build status](https://travis-ci.com/tobiashofmann88/iucnsim.svg?branch=master)](https://travis-ci.com/tobiashofmann88/iucnsim)
[![Codecov test coverage](https://codecov.io/gh/tobiashofmann88/iucnsim/branch/master/graph/badge.svg)](https://codecov.io/gh/tobiashofmann88/iucnsim?branch=master)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

Use `iucnsim` to simulate the future [IUCN conservation status](https://www.iucnredlist.org) distribution as well as extinctions for your taxon group of interest. All you will need is a list of binomial species names (**species list**) for your species of interest. The `iucnsim` package offers a range of functions that allow you to quickly and conveniently download all available IUCN RedList information for those species and to start modeling status transition rates and extinction probabilities to simulate the future of these species.

The trends (status transition rates) that `iucnsim` will use to simulate the future development of your target species will be determined based on observed status transitions in the history of IUCN status assessments for a representative taxonomic group (**reference group**). This can be any taxonomic group of your chosing, but it usually makes sense that this group i) contains (most of) your target species present in the **species list** and ii) is suficiently large and well assessed to be able to find several status transition events.

The following tutorial will guide you through the whole workflow. For more information see our published manuscript at [https://doi.org/10.1111/ecog.05110](https://doi.org/10.1111/ecog.05110) (Andermann et al., 2021). `iucnsim` is also available as a [bash command line program](https://github.com/tobiashofmann88/iucn_extinction_simulator) that can be downloaded via conda.

## Installation

You can easily install the `iucnsim` R-package directly from GitHub with `devtools`:

```R
install.packages("devtools")
library(devtools)

install_github("tobiashofmann88/iucnsim")
library(iucnsim)
```

`iucnsim` uses the `rredlist` R-package to access IUCN data. Therefore make sure that `rredlist` is installed and loaded:

```R
install.packages('rredlist')
library(rredlist)
```

Most of the `iucnsim` code is written in python. To load the python functions inot R you will also need to install the `reticulate` package:

```R
install.packages(reticulate)
library(reticulate)
```

Once you have the `reticulate` library loaded, you can load all necessary python functions into R from the `iucnsim` python github repo:

```R
reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
```

Good to go!

## Apply for IUCN API key

This tutorial uses pre-compiled IUCN data, and therefore does not require an IUCN API key, so **you can skip this step for now**. If you plan on running `iucnsim` for your own **species list** and **reference group**, you will first need to apply for an IUCN key (see information below). However, `iucnsim` has access to a range of [pre-compiled reference groups](https://github.com/tobiashofmann88/iucn_extinction_simulator/tree/master/data/precompiled/iucn_history), which enable processing without requiring an IUCN API key. There is no need to download these, the program will find them automatically.

To use the full functionality of `iucnsim` you will have to apply for an IUCN API key. This key is necessary to download data from IUCN, which is done internally in `iucnsim` using the `rredlist` package. It is easy to apply for an API key, just follow [this link](https://apiv3.iucnredlist.org/api/v3/token), it will then take up to a couple of days before you receive your API key.

## Tutorial

### Load all necessary libraries

```R
library(iucnsim)
library(reticulate)
library(rredlist)
reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
```

### Load data and define settings

For the tutorial we will be using a list of species for the order Carnivora. The data can be loaded with `data('carnivora')` and will be stored as a list-object called `species_list`:

```R
# load tutorial data, will be saved as species_list
data('carnivora')
# set reference group and define iucn key
reference_group = "Mammalia"
reference_rank = "class" # the taxonomic rank of your reference group, e.g. genus, family, order, class, etc.
iucn_key='insert_your_iucn_key_here' #(for this tutorial you can use a made-up dummy key)
```

### Download the IUCN history of your chosen reference group

As you see we are using the whole class `Mammalia` as our **reference group**. This means that we will model the future of our Carnivora species based on the average trends we observe across all mammals. The trends we are looking for are transitions from one IUCN status to another in the history of IUCN assessments for this group, e.g. a species moving from status VU (vulnerable) to EN (endangered).

```R
outdir = 'data/iucn_sim/iucn_data' # define where you want the output files to be stored
# get iucn history of reference group, will be written to file
iucn_history_file = get_iucn_history(reference_group=reference_group,
                                        reference_rank=reference_rank,
                                        iucn_key=iucn_key,
                                        outdir=outdir)
```

Choosing `Mammalia` as a reference group for our Carnivora species may or may not be a good decision, since one could argue that Carnivora species are exposed to higher or different threats than the average mammal. On the other hand it makes sense to choose a group that is large enough and well enough assessed so we can find and extract a decent number of status transition events in the IUCN history of this group, so we can better estimated the status transition rates. This trade-off between large/informative enough and representative enough can be a challenge and needs to be decided on a per-study basis.

To make a more informed decision whether you picked a reference group with sufficient observed status changes, you can use the `evaluate_iucn_history()` function:

```R
counted_status_transition_events = evaluate_iucn_history(iucn_history_file)

>>> output:
Current IUCN status distribution in reference group: {'CR': 212, 'DD': 871, 'EN': 505, 'EX': 4, 'LC': 3297, 'NT': 345, 'VU': 536}
Counted the following transition occurrences in IUCN history of reference group:
    LC  NT  VU  EN  CR  DD  EX
LC    0  52  34   7   3  25   0
NT   92   0  45  15   3  19   0
VU   46  45   0  76   7  23   0
EN    7  14  65   0  32   2   0
CR    2   2   7  38   0   3   3
DD  112  22  30  37  14   0   1
EX    0   0   0   0   2   1   0
```

This table tells us that e.g. there were 52 occurrences of taxa changing from LC (least concern) to NT (near threatened) observed in the IUCN history of all mammals. Similarly 7 taxa were observed changing from EN (endangered) to LC (least concern), and so on. As long as you have several counted status transitions for a range of different transition types, your reference group is sufficiently informative. These counts will be used later on to estimate transition rates for every possible type of status change. Note that any species of the status EW (extinct in the wild) are set to EX (extinct) by `iucnsim`.

### Load current IUCN status for species in `species_list`

Above we downloaded all available IUCN status information for the `reference_group`, but we may have species in our `species_list` that are not part of the `reference_group`. The current status for all species that are found in the reference group will be extracted from the already downloaded `iucn_history_file`, speeding up the procedure. The statuses of any remaining species will need to be downloaded individually, which can take a few minutes.

```R
# get most recent status for each taxon in target species list
extant_taxa_current_status = get_most_recent_status_target_species(species_list=species_list,
                                                                    iucn_history_file=iucn_history_file,
                                                                    iucn_key=iucn_key,
                                                                    outdir=outdir)
```

### Download information about possibly extinct taxa from IUCN

In 2020, IUCN released a list of taxa that are still officially listed under one of the extant IUCN statuses (LC, NT, VU, EN, CR, or DD), but which are likely extinct. `iucnsim` offers the option to easily aaccess this information and set those taxa to EX in the IUCN history of the reference group before estimating transition rates. For now we will just load this information, and we will apply it later on in the tutorial. Alternatively you can also provide your own custom list of taxa that you have reason to believe are extinct. The reaulting `possibly_extinct_taxa` dataframe contains one column with binomial species names and a second column with the year the species is expected to have disappeared.

```R
possibly_extinct_taxa = get_possibly_extinct_iucn_info(iucn_history_file,
                                                    outdir=outdir)
```

### Estimate status transition rates

Now it is time to estimate the rates of status transitions for each transition type based on the counts of these events in the IUCN history of our **reference group**. `iucnsim` runs an MCMC (Markov-Chain Monte Carlo) algorithm to estimate a range of transition rates for each transition type that may have produced the observed count of transitions. You can choose how many rates to sample for each transition type, the default of 100 is usually enough.

One central setting is the `extinction_probs_mode`, which decides the method that is being used to determine the extinction probabilities for each status. When set to `0` the function will calculate extinction probabilities based on the IUCN criterion E definitions for endangered statuses, sensu [Mooers et al. 2008](https://doi.org/10.1371/journal.pone.0003700). When set to `1` the function will instead estimate the extinction probabilities based on empirically observed transitions in the IUCN history of the reference group from extant IUCN statuses to EX (equivalent to how transition rates between extant statuses are being estimated, sensu [Monroe et al., 2019](https://doi.org/10.1098/rsbl.2019.0633)). These two options usually result in significantly different future predictions, and it is therefore important to fully understand the underlying assumptions (read more in the programs [published manuscript](https://doi.org/10.1111/ecog.05110)).

The `extinction_probs_mode=0` scenario is based on hypothetical extinction probabilities, which may not capture the true extinction probabilities and are technically not meant to be applied in this manner by IUCN. These will be the same for all taxa and are not affected by the identity of the species in the **reference group** or **species list**. However, to make this approach less static and more tailored towards the target species, `iucn_sim` allows for including information about generation lengths of the target species. These data can be appended as an additional column to the `extant_taxa_current_status` dataframe and will be considered when calculating extinction probabilities for each species. Uncertainties with the generation length data can be propagated by providing multiple generation length values for each species, e.g. multiple values drawn from uncertainty interval (in that case append multiple columns).

The `extinction_probs_mode=1` scenario is likely to underestimate the true extinciton probabilities, due to the time lag between a species goning extinct and this being registered in the IUCN system. Therefore it is recommendable for this scenario to include the information about `possibly_extinct_taxa`, as this can lead to more observed transitions from extant statuses towards EX.

```R
outdir = 'data/iucn_sim/transition_rates'
transition_rates_out = estimate_transition_rates(extant_taxa_current_status,
                                                  iucn_history_file,
                                                  outdir,
                                                  extinction_probs_mode=0,
                                                  possibly_extinct_list=possibly_extinct_taxa,
                                                  rate_samples=100)
```

### Simulate future

Now where we have compiled the current IUCN information for our `species_list` and the status transition rates and extinction probabilities, se are ready to start the future simulations. Let us simulate for the next 50 years.

```R
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
```

There are different ways of displaying the simulation results. The main output items provide a dataframe of simulated extinction times for all target taxa (`extinction_times`), the future diversity trajectory of the target group, including the 95% uncertainty interval (`future_div_min_max`), and the mean status count estimates through time (`status_through_time_trajectories`). The function also produces a set of plots and output files in the output folder, among them a pie-chart of the current and future status distribution of our Carnivora species:

<img src="https://github.com/tobiashofmann88/iucnsim/blob/master/img/status_pie_chart.png" width="900">

### Estimate extinction rates

Finally we can estimate the species-specific extinction rates/risks from the simulation results. For this purpose `iucnsim` runs a separate MCMC for each species, based on the simulated times of extinction. To increase the accuracy of these estimates, particularly for species with low extinction rates, it is **recommendable to run the simulations for at least 10,000 simulation replicates** before estimating the extinction rates. Therefore change `n_sim=100` in the code sample above to `n_sim=10000` and rerun the `run_future_sim()` function. Depending on the number of target species this may take several minutes.

Once you have produced 10,000 simulation replicates you can estimate the species-specific extinction rates using the `estimate_extinction_rates()` function.

```R
outdir = 'data/iucn_sim/extinction_rates'
ext_rates = estimate_extinction_rates(extinction_times,
                                      sim_years,
                                      outdir,
                                      load_from_file=FALSE)
```

This function returns the species-specific extinction rates (`ext_rates`), which inherently contain the possibilities of future status changes based on the trends observed in the reference group, and are based on the current conservation status of each species (as well as species' generation length, if provided by user).
