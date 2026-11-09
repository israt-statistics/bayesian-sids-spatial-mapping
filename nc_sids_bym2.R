library(sf)
library(ggplot2)
library(mapview)
library(spdep)
library(INLA)
library(patchwork)
library(htmlwidgets)
nc<-st_read(system.file("shape/nc.shp",package="sf"))
overall_rate<-sum(nc$SID74)/sum(nc$BIR74)
nc$expected<-nc$BIR74*overall_rate
nc$SIR<-nc$SID74/nc$expected
res<-nc[order(-nc$SIR),]
head(st_drop_geometry(res)[,c("NAME","BIR74","SID74","expected","SIR")],10)
mapview(nc,zcol="SIR")
m<-mapview(nc, zcol="SIR",layer.name="SIR")
saveWidget(m@map,"SIR_interactive.html", selfcontained = TRUE)
p1<-ggplot(nc)+geom_sf(aes(fill=SIR))+labs(title="SIR across North Carolina Counties", fill="SIR")
p1
nb<-poly2nb(nc)
summary(nb)
adj_file<-tempfile(fileext=".adj")
nb2INLA(adj_file,nb)
g<-inla.read.graph(adj_file)
dd<-st_drop_geometry(nc)
dd$idarea<-1:nrow(dd)
formula<-SID74~1+f(idarea,model="bym2",graph = g,scale.model = TRUE,hyper=list(prec=list(prior="pc.prec",param=c(1,0.01)),phi=list(prior="pc",param=c(0.5,0.5))))
model_fit<-inla(formula,family ="poisson",data=dd,E=expected,control.predictor = list(compute=TRUE) )
summary(model_fit)
nc$RR<-model_fit$summary.fitted.values$mean
nc$RR_low<-model_fit$summary.fitted.values$`0.025quant`
nc$RR_high<-model_fit$summary.fitted.values$`0.975quant`
st_drop_geometry(nc)[nc$NAME %in% c("Anson","Northampton","Washington"),c("NAME","SIR","RR","RR_low","RR_high")]
sum(nc$RR>1)
sum(nc$RR_low>1)
nc$NAME[nc$RR_low>1]
lims<-range(c(nc$SIR,nc$RR))
p_sir<-ggplot(nc)+geom_sf(aes(fill=SIR))+scale_fill_viridis_c(limits=lims)+ggtitle("Raw SIR")
P_rr<-ggplot(nc)+geom_sf(aes(fill=RR))+scale_fill_viridis_c(limits=lims)+ggtitle("smoothed RR(BYM2)")
p_sir+P_rr
ggplot(nc,aes(SIR,RR))+geom_point(aes(size=BIR74))+geom_abline(slope=1,intercept=0,linetype="dashed")