cat("################","Generation ",gen," #########################","\n")

cat(date(),"\n")

cat("\n",paste("tiempo = ",round(as.numeric(proc.time()[3]-hora.1),2), "s",sep=""),"\n",sep="")

cat("AIC =",round(AIC(-fitb,npar),4),"\n")

cat("Total likelihood =",round(fitb,4),"\n")

cat("Partial likelihoods: \n")
print(round(fitbp,4))

cat("\n","step size :",sigma.step,"\n")

cat("Optimal parameters","\n")

colnames(MU) = parcol
rownames(MU) = parrow

print(MU)

#cat("Initial Biomass","\n")
#print(MU[c("M","B0", "plankton.a"),])

cat("\n")

