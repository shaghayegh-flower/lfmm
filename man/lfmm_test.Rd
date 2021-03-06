% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lfmm.R
\name{lfmm_test}
\alias{lfmm_test}
\title{Statistical tests with latent factor mixed models (linear models)}
\usage{
lfmm_test(Y, X, lfmm, calibrate = "gif")
}
\arguments{
\item{Y}{a response variable matrix with n rows and p columns.
Each column is a response variable (numeric).}

\item{X}{an explanatory variable matrix with n rows and d columns.
Each column corresponds to an explanatory variable (numeric).}

\item{lfmm}{an object of class \code{lfmm} returned by the \link{lfmm_lasso}
or \link{lfmm_ridge} function}

\item{calibrate}{a character string, "gif" or "median+MAD". If the "gif" option is set (default),
significance values are calibrated by using the genomic control method. Genomic control
uses a robust estimate of the variance of z-scores called "genomic inflation factor".
If the "median+MAD" option is set, the pvalues are calibrated by computing the median and MAD of the zscores. If \code{NULL}, the
pvalues are not calibrated.}
}
\value{
a list with the following attributes:
\itemize{
\item B a p x d matrix of effect sizes for each locus and each explanatory variable. Note that the direction
of association is "Y explained by X",
\item calibrated.pvalue a p x d matrix which contains calibrated p-values for each explanatory variable,
\item gif a numeric value for the genomic inflation factor,
\item epsilon.sigma2 a vector of length p containing the residual variances for each locus,
\item B.sigma2 a matrix of size n x (d+K) that contains the variance of effect sizes for the d explanatory variables
and the K latent factors. It could be used to evaluate the proportion of the response variance (genetic variation)
explained by the exposure (X) and latent factors (U) at each locus,
\item score a p x d matrix which contains z-scores for each explanatory variable (columns of X), before calibration.
This is equal to B\link{,j}/sqrt(B.sigma2\link{,j}) for variable j.
\item pvalue a p x d matrix which contains uncalibrated p-values for each explanatory variable before calibration.
This may be useful to users preferring alternative methods to the GIF, like the local FDR method.
\item calibrated.score2  a p x d matrix which contains squared Z-score after calibration.
This may be useful to expert users who may want to perform test recalibration with a different numeric value
for the GIF.
}
}
\description{
This function returns significance values for the association between each column of the
response matrix, Y, and the explanatory variables, X, including correction for unobserved confounders
(latent factors). The test is based on an LFMM fitted with a ridge or lasso penalty (linear model).
}
\details{
The response variable matrix Y and the explanatory variables X are centered. Note that
scaling the Y and X matrices would convert the effect sizes into correlation coefficients. Calibrating
p-values means that their distribution is uniform under the null-hypothesis. Additional corrections are
required for multiple testing. For this, Benjamini-Hochberg or Bonferroni adjusted p-values could be obtained from
the calibrated values by using one of several the packages that implements multiple testing corrections.
}
\examples{

library(lfmm)

## a GWAS example with Y = SNPs and X = phenotype
data(example.data)
Y <- example.data$genotype
X <- example.data$phenotype

## Fit an LFMM with K = 6 factors
mod.lfmm <- lfmm_ridge(Y = Y, 
                       X = X, 
                       K = 6)

## Perform association testing using the fitted model:
pv <- lfmm_test(Y = Y, 
                X = X, 
                lfmm = mod.lfmm, 
                calibrate = "gif")

## Manhattan plot with causal loci shown

pvalues <- pv$calibrated.pvalue
plot(-log10(pvalues), pch = 19, 
     cex = .2, col = "grey", xlab = "SNP")
points(example.data$causal.set, 
      -log10(pvalues)[example.data$causal.set], 
       type = "h", col = "blue")


## An EWAS example with Y = methylation data and X = exposure
data("skin.exposure")
Y <- scale(skin.exposure$beta.value)
X <- scale(as.numeric(skin.exposure$exposure))

## Fit an LFMM with 2 latent factors
mod.lfmm <- lfmm_ridge(Y = Y,
                       X = X, 
                       K = 2)
                       
## Perform association testing using the fitted model:
pv <- lfmm_test(Y = Y, 
                X = X,
                lfmm = mod.lfmm, 
                calibrate = "gif")
                
## Manhattan plot with true associations shown
pvalues <- pv$calibrated.pvalue
plot(-log10(pvalues), 
     pch = 19, 
     cex = .3,
     xlab = "Probe",
     col = "grey")
     
causal.set <- seq(11, 1496, by = 80)
points(causal.set, 
      -log10(pvalues)[causal.set], 
       col = "blue")
}
\seealso{
\link{glm_test}
}
\author{
cayek, francoio
}
