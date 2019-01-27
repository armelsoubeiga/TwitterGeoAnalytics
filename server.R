library(shiny)
library(leaflet)
library(shinydashboard)
library(graphics)
suppressPackageStartupMessages(library(googleVis))
library(ggforce)

#################################################################################
#################################################################################
#load script run source code
#source("code_source.r", local = TRUE)


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


##analyse variographique
coordinates(RHA)= ~longitude+latitude
RHA <- RHA[-zerodist(RHA)[,1],] 
tweet.vgm<- gstat::variogram(num~ 1 , RHA, cutoff=1)
tweet.fit <- autofitVariogram(num~ 1 , RHA,model = c("Sph"))

## Krigeage interpolation des la densit? sur tout le domaine d'?tude
g<-gstat(id="num", formula=num ~ 1, data=RHA,set = list(idp = .5))
tweet.kriged<- predict(g, model=tweet.fit, newdata=join2) # join2 est la grille dans le fichier construction de la grille. 


####################################################################################
####################################################################################
####################################################################################

iddep <- c("01","03","07","15","26","38","42","43","63","69","69","73","74")
dep <- cbind(iddep,c("Ain","Allier","Ardèche","Canta", "Drôme", "Isère", "Loire",
                     "Haute-Loire","Puy-de-Dôme", "Rhône", "Métropole de Lyon", "Savoie", "Haute-Savoie"))

server <-function(input, output, session){
  
  
  #data
  points <- eventReactive(input$dep, {
    index = which(dep[,2] == input$dep)
    RHA[RHA$DEP==dep[index,1],]
  }, ignoreNULL = FALSE)
  

  
  #
  output$CountryMap <- renderLeaflet({
    RHA <- points()
    pal <- colorNumeric(palette = "#FFA500",  domain = RHA$num)
    leaflet() %>% addTiles() %>% addProviderTiles(input$Esri) %>%
      #setView(lng = 31.165580, lat = 48.379433, zoom = 6) %>%
      addCircles(lng = as.numeric(RHA$longitude), lat = as.numeric(RHA$latitude), weight = 1, radius = sqrt(RHA$num)*30, popup = paste(RHA$LIBCOM, ": ", RHA$num), color = "#FFA500", fillOpacity =50 ) %>%
      addLegend("bottomleft", pal = pal, values = RHA$num, title = "Taux de tweets") %>%
      
      #Easy buttons code
      addEasyButton(easyButton(
        icon="fa-globe", title="Zoom to Level 1",
        onClick=JS("function(btn, map){ map.setZoom(1); }"))) %>%
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
  })
  
  #Action on selectInput
  output$pieChart <- renderPlot({
    RHA <- points()
    rVal <- quantile(RHA$num,c(1,0.75,0.25,0.0),type=1)
    circles <- data.frame(
      x0 = c(1:4),
      y0 =  c(1:4),
      ray=c(1,0.75,0.25,0.1),
      r = rVal)
    ggplot() + geom_circle(data = circles, mapping = aes(x0 = x0,  y0 = y0, r = ray,fill=r), fill = "#FFA500",show.legend = NA) + 
      coord_fixed() +
      theme(panel.background = element_blank(),
            axis.ticks = element_blank(),
            panel.grid = element_blank(),
            axis.text = element_blank(),
            axis.title = element_blank()) +
      annotate("text", x = circles$x0, y = circles$y0, label = circles$r, size = 5)
    
  })

  #Action on krieage
  output$carto1 <- renderPlot({
    par(mar = c(0, 0, 0, 0))
    plot(carteR[carteR$code_insee=="82",], border="black", col="#FEE08B")
  })
  
  output$carto2 <- renderPlot({
    #Représentons 
    par(mar = c(0, 0, 0, 0))
    plot(pts)
    plot(carteRH,border = "red",lwd=3,add = T)
    })
  
  output$carto3 <- renderPlot({
    #representation des points
    par(mar = c(0, 0, 0, 0))
    plot(join2)
    plot(carteRH,border="red",lwd=3,add=T)
  })

  output$carto4 <- renderPlot({
    par(mar = c(0, 0, 0, 0))
    plot(tweet.vgm, tweet.fit$var_model, main = "Fitted variogram")
  })
  output$carto5 <- renderPlot({
    par(mar = c(0, 0, 0, 0))
    spplot(tweet.kriged,"num.pred",col.regions=heat.colors(50))
  })
  
  output$image <- renderPlot({
    #library(imager)
    #image <- load.image('www/image.jpg')
    library(raster) 
    image<- stack('www/image.jpg')
    plotRGB(image)
  })
 
}

