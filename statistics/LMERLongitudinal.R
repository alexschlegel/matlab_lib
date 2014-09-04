#! /usr/bin/Rscript --vanilla
library(lme4)

#some dark magic to get the p-values from an LME analysis
p.values.lmer <- function(x) {
  summary.model <- summary(x)
  data.lmer <- data.frame(model.matrix(x))
  names(data.lmer) <- names(fixef(x))
  names(data.lmer) <- gsub(pattern=":", x=names(data.lmer), replacement=".", fixed=T)
  names(data.lmer) <- ifelse(names(data.lmer)=="(Intercept)", "Intercept", names(data.lmer))
  string.call <- strsplit(x=as.character(x@call), split=" + (", fixed=T)
  var.dep <- unlist(strsplit(x=unlist(string.call)[2], " ~ ", fixed=T))[1]
  vars.fixef <- names(data.lmer)
  formula.ranef <- paste("+ (", string.call[[2]][-1], sep="")
  formula.ranef <- paste(formula.ranef, collapse=" ")
  formula.full <- as.formula(paste(var.dep, "~ -1 +", paste(vars.fixef, collapse=" + "), 
                  formula.ranef))
  data.ranef <- data.frame(x@frame[, 
                which(names(x@frame) %in% names(ranef(x)))])
  names(data.ranef) <- names(ranef(x))
  data.lmer <- data.frame(x@frame[, 1], data.lmer, data.ranef)
  names(data.lmer)[1] <- var.dep
  out.full <- lmer(formula.full, data=data.lmer, REML=F)
  p.value.LRT <- vector(length=length(vars.fixef))
  for(i in 1:length(vars.fixef)) {
    formula.reduced <- as.formula(paste(var.dep, "~ -1 +", paste(vars.fixef[-i], 
                       collapse=" + "), formula.ranef))
    out.reduced <- lmer(formula.reduced, data=data.lmer, REML=F)
    print(paste("Reduced by:", vars.fixef[i]))
    print(out.LRT <- data.frame(anova(out.full, out.reduced)))
    #p.value.LRT[i] <- round(out.LRT[2, 8], 6)
    p.value.LRT[i] <- out.LRT[2, 8]
  }
  summary.model$coefficients <- cbind(summary.model$coefficients, p.value.LRT)
  summary.model$methTitle <- c("\n", summary.model$methTitle, 
                           "\n(p-values from comparing nested models fit by maximum likelihood)")
  print(summary.model)
  
  print("***p-values***")
  print(p.value.LRT)
}

#get the data file path
args <- commandArgs(TRUE)
data_file <- args[1]

#load the data, a csv file that should have "subject","group","time", and "response" columns
d <- read.table(data_file,header=T,sep=",",quote="\"")

#perform the analysis
fit <- lmer(response ~ group*time + (1|subject), data=d)
p.values.lmer(fit)

detach("package:lme4")
