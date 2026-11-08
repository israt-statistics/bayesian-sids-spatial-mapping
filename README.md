# Bayesian Spatial Smoothing of SIDS Risk in North Carolina Counties (1974)

## Overview
Sudden infant death syndrome (SIDS) is the sudden, unexplained death of an infant under one year of age. This project uses county-level SIDS data from North Carolina in 1974 to identify counties with more deaths than expected. 

Because counties differ in the number of births, deaths cannot be compared directly. So I calculated the standardized incidence ratio(SIR). SIR compares the observed deaths with the number expected under the statewide rate. An SIR above 1 means more deaths than expected, and below 1 means fewer.

However, SIR is unstable in small counties, where the expected count is low. A few extra cases can change the ratio a lot. It also gives no measure of uncertainty. So I fitted a Bayesian BYM2 model in R-INLA. This model borrows information from the neighbouring counties and gives smoothed relative risks with credible interval.

- **Data:** `nc.shp` from the `sf` package (100 counties; `SID74` = SIDS deaths, `BIR74` = live births, 1974)
  
- **Methods:** raw SIR, then a Poisson BYM2 model in R-INLA

- **Output:** county adjacency network, maps of raw SIR (static and interactive) and smoothed RR, and a scatter plot of SIR  against RR.

## Methods

### 1. Raw SIR

Expected deaths = births (BIR74) x statewide SIDS rate.
The statewide rate is total SID74 divided by total BIR74.
SIR = observed deaths / expected deaths. 

### 2. Neighbourhood structure 

Counties that share a border are defined as neighbours (spdep, poly2nb).
The 100 counties have 490 links in total.
Each county has 4.9 neighbours on average ( range 2 to 9).
No county is isolated. 
This network is the spatial structure used by the BYM2 model.

![County adjacency network](adjacency_graph.png)
