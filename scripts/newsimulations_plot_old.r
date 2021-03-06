# args<-commandArgs(T)
rm(list = ls())
source("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\scripts\\utils.r")
library("ggplot2")
library("scales") 
library("grid") 

infile<-"E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\allresults.dump"
df=read.table(infile,header=T)

snpvec=c(10^(1:6 ),3e6)
#Nvec=sapply(snpvec,approxN,delta=1e-6)
#df1=data.frame(Nsnps=snpvec,N=Nvec)

breakvec=c(0.005,0.01,0.025,0.05)
labelvec=c("0.005","0.01","0.025","0.05")

fixdeltaphifp=df[df$Phi==1 & df$Delta==1e-6 & df$FPR==0.05 & df$Nsnps<=100000,]
fixdeltaphifp2=df[df$Phi==1 & df$Delta==.001 & df$FPR==0.05 & df$Nsnps<=100000,]
fixdeltaphifp3=df[df$Phi==1 & df$Delta==.01 & df$FPR==0.05 & df$Nsnps<=100000,]
theorycopy=fixdeltaphifp
theorycopy$Power=apply(theorycopy,1,function(x){llrpower(n=x[1],N=1000,delta=1e-6,alpha=0.045)})
fixdeltaphifp$Type<-rep("Delta 1e-6",dim(fixdeltaphifp)[1])
theorycopy$Type<-rep("Theory",dim(theorycopy)[1])
fixdeltaphifp2$Type<-rep("Delta 0.001",dim(fixdeltaphifp2)[1])
fixdeltaphifp3$Type<-rep("Delta 0.01",dim(fixdeltaphifp3)[1])
combined=rbind(fixdeltaphifp,fixdeltaphifp2,fixdeltaphifp3)

library(reshape2)

p<-ggplot(combined,aes(x=Nsnps,y=Power,shape=Type))+geom_line(lwd=1)+xlab("Number of SNPs")+geom_point(size=2)  
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\simplepower_2m_100.png",width=2800,height=1800,res = 400)
print(enhance(p))
dev.off()



fixdeltansnpsphi=df[df$Nsnps==5000 & df$Delta==1e-6 & df$Phi==1,]
theorycopy1=fixdeltansnpsphi
theorycopy1$Power=apply(theorycopy1,1,function(x){theorypower(n=5000,N=1000,delta=1e-6,alpha=x[2])})
fixdeltansnpsphi$Type<-rep("Empirical",dim(fixdeltansnpsphi)[1])
theorycopy1$Type<-rep("Theory",dim(theorycopy1)[1])

combined=rbind(fixdeltansnpsphi,theorycopy1)

p<-ggplot(combined,aes(x=FPR,y=Power,linetype=Type))+geom_line(lwd=1)+ylim(0,1) + scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\fp_vs_power.png")
print(enhance(p))
dev.off()

fixdeltansnps=df[df$Delta==1e-6,]
theorycopy2=fixdeltansnps
theorycopy2$Power=apply(theorycopy2,1,function(x){relativetheorypower(n=x[1],N=1000,delta=1e-6,alpha=x[2],phi=x[5])})
#write.table(fixdeltansnps,file="emp_relatives.txt",quote=F,row.names=F,col.names=T)
#write.table(theorycopy2,file="theory_relatives.txt",quote=F,row.names=F,col.names=T)
fixdeltansnps$Type<-rep("Empirical",dim(fixdeltansnps)[1])
theorycopy2$Type<-rep("Theory",dim(theorycopy2)[1])

combined=rbind(fixdeltansnps,theorycopy2)
p<-ggplot(combined,aes(x=FPR,y=Power,colour=as.factor(Phi),linetype=Type))+geom_line(lwd=1)+facet_wrap(~Nsnps,ncol=4)+
  theme(strip.text.x = element_text(size=14))+ scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
p<-p+scale_colour_manual(values=cbbPalette,name="Relatedness")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\phi_effect.png",width=2800,height=2800,res = 200)
print(enhance(p))
dev.off()

p<-ggplot(fixdeltansnps[fixdeltansnps$FPR==0.05 & fixdeltansnps$Phi<1,],aes(x=Nsnps,y=Power,linetype=Type,colour=as.factor(Phi)))+geom_line(lwd=1.5)
#p<-p+ scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),labels = trans_format("log10", math_format(10^.x)) ) 
p<-p+ scale_x_log10(breaks=c(1000,2000,5000,10000,20000,40000,50000),labels=c("1000","2000","5000","10000","20000","40000","50000"))
p<-p+scale_colour_manual(values=cbbPalette,name="Relatedness")+xlab("Number of SNPs")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\phi_effect_power.png",width = 600, height = 480)
print(enhance(p))
dev.off()

#p<-ggplot(combined[combined$Nsnps==5000,],aes(x=FPR,y=Power,linetype=Type,colour=as.factor(Phi)))+geom_line(lwd=1.5) + scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
p<-ggplot(fixdeltansnps[fixdeltansnps$Nsnps==5000,],aes(x=FPR,y=Power,colour=as.factor(Phi)))+geom_line(lwd=1) + scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
p<-p+scale_colour_manual(values=cbbPalette,name="Relatedness")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\phi_effect_singlepanel.png",width = 600, height = 480)
print(enhance(p))
dev.off()


#ROC curve
fixnsnpsphi=df[df$Phi==1,]
theorycopy3=fixnsnpsphi
theorycopy3$Power=apply(theorycopy3,1,function(x){theorypower(n=x[1],N=1000,delta=x[4],alpha=x[2])})
fixnsnpsphi$Type<-rep("Empirical",dim(fixnsnpsphi)[1])
theorycopy3$Type<-rep("Theory",dim(theorycopy3)[1])

combined=rbind(fixnsnpsphi,theorycopy3)
p<-ggplot(fixnsnpsphi,aes(x=FPR,y=Power,colour=as.factor(Delta)))+geom_line(lwd=1)+facet_wrap(~Nsnps,ncol=4)+theme(strip.text.x = element_text(size=14))+ scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
p<-p+scale_colour_manual(values=cbbPalette,name="Mismatch Rate")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\delta_effect.png",width = 3000, height = 3000,res=200)
print(enhance(p))
dev.off()

p<-ggplot(fixnsnpsphi[fixnsnpsphi$Nsnps==5000,],aes(x=FPR,y=Power,colour=as.factor(Delta)))+geom_line(lwd=1.5)+ scale_x_log10(breaks=breakvec,labels=labelvec) +xlab("False Positive Rate")
p<-p+scale_colour_manual(values=cbbPalette,name="Mismatch Rate")
png("E:\\Privacy Code Works\\beacon_distribute\\beacon_distribute\\delta_effect_singlepanel.png",width = 600, height = 480)
print(enhance(p))
dev.off()

