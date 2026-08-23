# Evaluate UNE-EN 689 chemical exposure from an Excel file

Reads the three sheets of the expoquimR UNE-EN 689 template (`Agents`,
`Measurements` and optionally `Additive_effects`) and returns a list
with the preliminary assessment of each agent, and if applicable, the
additive effects calculation by group.

## Usage

``` r
une689_from_excel(path)
```

## Arguments

- path:

  Character. Path to the `.xlsx` file.

## Value

A list with the elements:

- `preliminary`:

  A list with one element per agent, each with `name`, `vla`,
  `days_table` and `result`.

- `additive`:

  `data.frame` with columns `group`, `agent`, `mean_ie` and
  `combined_ie`, or `NULL` if there is no additive effects sheet.

## Examples

``` r
path <- system.file("plantillas", "plantilla_une689.xlsx",
                    package = "expoquimR")
res <- une689_from_excel(path)
res$preliminary
#> $Toluene
#> $Toluene$name
#> [1] "Toluene"
#> 
#> $Toluene$vla
#> [1] 50
#> 
#> $Toluene$days_table
#>   day     ED     IE
#> 1   1 10.000 0.2000
#> 2   2  9.000 0.1800
#> 3   3  5.625 0.1125
#> 
#> $Toluene$result
#> [1] "NO DECISION"
#> 
#> $Toluene$statistics
#> $Toluene$statistics$n
#> [1] 6
#> 
#> $Toluene$statistics$distribution_type
#> [1] "Lognormal"
#> 
#> $Toluene$statistics$MA
#> [1] 9.4375
#> 
#> $Toluene$statistics$DS
#> [1] 2.539377
#> 
#> $Toluene$statistics$MG
#> [1] 9.129882
#> 
#> $Toluene$statistics$DSG
#> [1] 1.33626
#> 
#> $Toluene$statistics$W_normal
#> [1] 0.9979167
#> 
#> $Toluene$statistics$pval_normal
#> [1] 0.9997338
#> 
#> $Toluene$statistics$W_lognormal
#> [1] 0.9667984
#> 
#> $Toluene$statistics$pval_lognormal
#> [1] 0.8702792
#> 
#> $Toluene$statistics$ut
#> [1] 2.187
#> 
#> $Toluene$statistics$lsc
#> [1] 17.2103
#> 
#> $Toluene$statistics$ur
#> [1] 5.866233
#> 
#> $Toluene$statistics$conformity
#> [1] "CONFORMITY"
#> 
#> $Toluene$statistics$eds
#> [1] 10.000  9.000  5.625 11.000  8.000 13.000
#> 
#> $Toluene$statistics$vla
#> [1] 50
#> 
#> 
#> 
#> $Xylene
#> $Xylene$name
#> [1] "Xylene"
#> 
#> $Xylene$vla
#> [1] 77
#> 
#> $Xylene$days_table
#>   day ED        IE
#> 1   1 20 0.2597403
#> 2   2 20 0.2597403
#> 
#> $Xylene$result
#> [1] "NO DECISION"
#> 
#> 
#> $Lead
#> $Lead$name
#> [1] "Lead"
#> 
#> $Lead$vla
#> [1] 0.15
#> 
#> $Lead$days_table
#>   day   ED        IE
#> 1   1 0.05 0.3333333
#> 2   2 0.08 0.5333333
#> 3   3 0.06 0.4000000
#> 
#> $Lead$result
#> [1] "NO DECISION"
#> 
#> $Lead$statistics
#> $Lead$statistics$n
#> [1] 6
#> 
#> $Lead$statistics$distribution_type
#> [1] "Lognormal"
#> 
#> $Lead$statistics$MA
#> [1] 0.06833333
#> 
#> $Lead$statistics$DS
#> [1] 0.0147196
#> 
#> $Lead$statistics$MG
#> [1] 0.06703226
#> 
#> $Lead$statistics$DSG
#> [1] 1.239483
#> 
#> $Lead$statistics$W_normal
#> [1] 0.9580121
#> 
#> $Lead$statistics$pval_normal
#> [1] 0.804296
#> 
#> $Lead$statistics$W_lognormal
#> [1] 0.9678492
#> 
#> $Lead$statistics$pval_lognormal
#> [1] 0.8776878
#> 
#> $Lead$statistics$ut
#> [1] 2.187
#> 
#> $Lead$statistics$lsc
#> [1] 0.1072014
#> 
#> $Lead$statistics$ur
#> [1] 3.751671
#> 
#> $Lead$statistics$conformity
#> [1] "CONFORMITY"
#> 
#> $Lead$statistics$eds
#> [1] 0.05 0.08 0.06 0.07 0.09 0.06
#> 
#> $Lead$statistics$vla
#> [1] 0.15
#> 
#> 
#> 
#> $Manganese
#> $Manganese$name
#> [1] "Manganese"
#> 
#> $Manganese$vla
#> [1] 0.2
#> 
#> $Manganese$days_table
#>   day   ED   IE
#> 1   1 0.12 0.60
#> 2   2 0.09 0.45
#> 3   3 0.15 0.75
#> 
#> $Manganese$result
#> [1] "NO DECISION"
#> 
#> $Manganese$statistics
#> $Manganese$statistics$n
#> [1] 6
#> 
#> $Manganese$statistics$distribution_type
#> [1] "Lognormal"
#> 
#> $Manganese$statistics$MA
#> [1] 0.1166667
#> 
#> $Manganese$statistics$DS
#> [1] 0.02160247
#> 
#> $Manganese$statistics$MG
#> [1] 0.1150293
#> 
#> $Manganese$statistics$DSG
#> [1] 1.201856
#> 
#> $Manganese$statistics$W_normal
#> [1] 0.9825868
#> 
#> $Manganese$statistics$pval_normal
#> [1] 0.9636699
#> 
#> $Manganese$statistics$W_lognormal
#> [1] 0.993374
#> 
#> $Manganese$statistics$pval_lognormal
#> [1] 0.9957854
#> 
#> $Manganese$statistics$ut
#> [1] 2.187
#> 
#> $Manganese$statistics$lsc
#> [1] 0.1719671
#> 
#> $Manganese$statistics$ur
#> [1] 3.008323
#> 
#> $Manganese$statistics$conformity
#> [1] "CONFORMITY"
#> 
#> $Manganese$statistics$eds
#> [1] 0.12 0.09 0.15 0.11 0.13 0.10
#> 
#> $Manganese$statistics$vla
#> [1] 0.2
#> 
#> 
#> 
res$additive
#>            group                                 description     agent mean_ie
#> Toluene        1         CNS effect (central nervous system)   Toluene  0.1642
#> Xylene         1         CNS effect (central nervous system)    Xylene  0.2597
#> Lead           2                       Haematopoietic effect      Lead  0.4222
#> Manganese      2                       Haematopoietic effect Manganese  0.6000
#> Manganese1     3 CNS effect (manganese also affects the CNS) Manganese  0.6000
#> Toluene1       3 CNS effect (manganese also affects the CNS)   Toluene  0.1642
#>            combined_ie   group_result
#> Toluene         0.4239    NO DECISION
#> Xylene          0.4239    NO DECISION
#> Lead            1.0222 NON-CONFORMITY
#> Manganese       1.0222 NON-CONFORMITY
#> Manganese1      0.7642    NO DECISION
#> Toluene1        0.7642    NO DECISION
```
