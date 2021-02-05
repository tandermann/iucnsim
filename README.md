# Welcome to the `iucnsim` R-package

[![Travis build status](https://travis-ci.com/tobiashofmann88/iucnsim.svg?branch=master)](https://travis-ci.com/tobiashofmann88/iucnsim)
[![Codecov test coverage](https://codecov.io/gh/tobiashofmann88/iucnsim/branch/master/graph/badge.svg)](https://codecov.io/gh/tobiashofmann88/iucnsim?branch=master)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

Use `iucnsim` to simulate the future [IUCN conservation status](https://www.iucnredlist.org) distribution as well as extinctions for your taxon group of interest. All you will need is a list of binomial species names (**species list**) for your species of interest. The `iucnsim` package offers a range of functions that allow you to quickly and conveniently download all available IUCN RedList information for those species and to start modeling status transition rates and extinction probabilities to simulate the future of these species.

The trends (status transition rates) that `iucnsim` will use to simulate the future development of your target species will be determined based on observed status transitions in the history of IUCN status assessments for a representative taxonomic group (**reference group**). This can be any taxonomic group of your chosing, but it usually makes sense that this group i) contains (most of) your target species present in the **species list** and ii) is suficiently large and well assessed to be able to find several status transition events.

The following tutorial will guide you through the whole workflow. For more information see our published manuscript at [https://doi.org/10.1111/ecog.05110](https://doi.org/10.1111/ecog.05110) (Andermann et al., 2021). `iucnsim` is [also available as a bash command line program](https://github.com/tobiashofmann88/iucn_extinction_simulator) that can be downloaded via conda.

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

1. Load all necessary libraries:

    ```R
    library(iucnsim)
    library(reticulate)
    library(rredlist)
    reticulate::source_python("https://raw.githubusercontent.com/tobiashofmann88/iucn_extinction_simulator/master/iucn_sim/iucn_sim.py")
    ```

2. Load the tutorial data, a list of species for the order Carnivora. The data will be stored as a list-object called `species_list`:

    ```R
    data('carnivora') # will be saved as species_list
    ```

