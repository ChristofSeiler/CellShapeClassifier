library(nodeHarvest)

# dataset: Exp15
# RESPONSE: 1 = adipcyte, 2 = control, 3 = myogenic, 4 = osteogenic
StemCellsExp15 <- read.table(file("./Exp15/cells_3rd_try.dat"),header=TRUE,sep=",")

# new dataset
# RESPONSE: 0 = myogenic, 1 = osteogenic
parent <- "./Exp18"
fields <- list.files(path=parent, patter="*.dat")
StemCellsExp18 <- matrix(nrow=0,ncol=0)
for(i in 1:length(fields)) {
	relpath <- paste(parent, fields[i], sep="/")
	print(relpath)
	T <- read.table(relpath,header=TRUE,sep=",")
	print(c("add ",dim(T)[1]," columns"))
	StemCellsExp18 <- rbind(StemCellsExp18,T)
}

# Exp15: myo <-> oesto
indMyo <- which(StemCellsExp15[,9]==3)
indOsteo <- which(StemCellsExp15[,9]==4)
ind <- c(indMyo,indOsteo)
StemCellsExp15Red <- StemCellsExp15[ind,]
X <- StemCellsExp15Red[,c(1:6,8)]
Y <- StemCellsExp15Red[,9]
Y[which(Y==3)] <- 0
Y[which(Y==4)] <- 1
NH <- nodeHarvest(X, Y, nodes=1000, maxinter=1)
pdf("exp15_termis_0myo_1osteo.pdf")#,width=15,height=8.9)
plot(NH)
dev.off()

# Exp15: myo <-> oesto
indMyo <- which(StemCellsExp15[,9]==3)
indAdipo <- which(StemCellsExp15[,9]==1)
ind <- c(indMyo,indAdipo)
StemCellsExp15Red <- StemCellsExp15[ind,]
X <- StemCellsExp15Red[,c(1:6,8)]
Y <- StemCellsExp15Red[,9]
Y[which(Y==3)] <- 0
Y[which(Y==1)] <- 1
NH <- nodeHarvest(X, Y, nodes=1000, maxinter=1)
pdf("exp15_termis_0myo_1adipo.pdf")#,width=15,height=8.9)
plot(NH)
dev.off()

# Exp15: myo <-> control
indMyo <- which(StemCellsExp15[,9]==3)
indControl <- which(StemCellsExp15[,9]==2)
ind <- c(indMyo,indControl)
StemCellsExp15Red <- StemCellsExp15[ind,]
X <- StemCellsExp15Red[,c(1:6,8)]
Y <- StemCellsExp15Red[,9]
Y[which(Y==3)] <- 0
Y[which(Y==2)] <- 1
NH <- nodeHarvest(X, Y, nodes=1000, maxinter=1)
pdf("exp15_termis_0myo_1control.pdf")#,width=15,height=8.9)
plot(NH)
dev.off()

# Exp15: myo <-> others
X <- StemCellsExp15[,c(1:6,8)]
Y <- StemCellsExp15[,9]
Y[which(Y!=3)] <- 1
Y[which(Y==3)] <- 0
NH <- nodeHarvest(X, Y, nodes=1000, maxinter=1)
pdf("exp15_termis_0myo_1others.pdf")#,width=15,height=8.9)
plot(NH)
dev.off()

# Exp18
X <- StemCellsExp18[,1:8]
Y <- StemCellsExp18[,9]-1
NH <- nodeHarvest(X, Y, nodes=1000, maxinter=2)
pdf("exp18_0myo_1osteo.pdf",width=15,height=8.9)
plot(NH)
dev.off()

# divide data into training and test data
n <- nrow(X)
training <- sample(1:n,round(n/2))
testing <- (1:n)[-training]

# train Node Harvest and plot and print the estimator
NH <- nodeHarvest(X[training,], Y[training], nodes=1000)
plot(NH)
print(NH, nonodes=6)

# predict on test data and explain prediction of the first sample in the test set
predicttest <- predict(NH, X[testing,], explain=1)
plot( predicttest, Y[testing] )

