library(rgdal)
library(readr)
library(automap)
library(gstat)


RHA <- read_delim("Data/geotweetRHA_2.txt", 
                          ";", escape_double = FALSE, trim_ws = TRUE)


pal <- colorNumeric(palette = "#FFA500",  domain = RHA$num)


RHA$royon <- sqrt(RHA$num)

##Krigeage

#Import Rhone alpes
carteR <- rgdal::readOGR("GeoData/regions-20140306-50m.shp")

#grille
carteRH <-carteR[carteR$code_insee=="82",]

# Coordonnees de letendue spatiale de bobo
grx<- seq(bbox(carteRH)[1,1],bbox(carteRH)[1,2],by= 0.01)
gry<- seq(bbox(carteRH)[2,1],bbox(carteRH)[2,2],by= 0.01)
x<-rep(grx, length(gry))
y<-rep(gry, length(grx))
y<-sort(y, decreasing=F)
pt<-data.frame(x=x, y=y)
pts<-SpatialPoints(coordinates(pt))

# Definition du systeme de coordonnees
proj4string(pts) <- proj4string(carteRH)

#Definition d'une table dattributs
mat <-data.frame(ID = paste("Random",1:length(pts) , sep = ""))
pts<- SpatialPointsDataFrame(pts, data = mat)
join <-sp::over(pts,carteRH)

#Rajout des identifiants
join<- data.frame(ID = pts@data[, "ID"], join)
#Identification des lignes avec NA
pos<-which(is.na(join[,"surf_km2"]))
# Suppression de ces lignes
join2<-join[-pos, ]
# Reinitialisation des noms de lignes
rownames(join2)<- NULL
#convertir ce nouveau data.frame
join2<-SpatialPointsDataFrame(coords = pts@coords [-pos, ],data = join2)
#construction de la grille
join2<-as(join2,"SpatialPoints")
gridded(join2)<-TRUE


##Krigeage
coordinates(RHA)= ~longitude+latitude
RHA <- RHA[-zerodist(RHA)[,1],] 
tweet.vgm<- gstat::variogram(num~ 1 , RHA, cutoff=1)
tweet.fit <- autofitVariogram(num~ 1 , RHA,model = c("Sph"))

## Krigeage interpolation des la densit? sur tout le domaine d'?tude
g<-gstat(id="num", formula=num ~ 1, data=RHA,set = list(idp = .5))
tweet.kriged<- predict(g, model=tweet.fit, newdata=join2) # join2 est la grille dans le fichier construction de la grille. 


