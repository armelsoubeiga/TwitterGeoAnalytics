library(shiny)
library(leaflet)
library(readxl)
library(shinydashboard)
library(graphics)
suppressPackageStartupMessages(library(googleVis))

iddep <- c("01","03","07","15","26","38","42","43","63","69","69","73","74")
dep <- cbind(iddep,c("Ain","Allier","Ardèche","Canta", "Drôme", "Isère", "Loire",
                     "Haute-Loire","Puy-de-Dôme", "Rhône", "Métropole de Lyon", "Savoie", "Haute-Savoie"))
Es <- c("Esri.WorldStreetMap","Esri.WorldImagery"," Esri.OceanBasemap"," Esri.NatGeoWorldMap")


ui <-navbarPage("Rhône Alpes", id="nav",
  tabPanel("Map Visualisation", div(class = "outer",
                      tags$head(
                        includeCSS("www/style.css")),
                      leafletOutput("CountryMap", width = "100%", height = "100%"),
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 70, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = "auto",
                                    
                                    selectInput("Esri", label = h4("Esri"), choices = c("", Es), selected = Es[1], width = "90%"),
                                    br(),br(),
                                    selectInput("dep", label = h4("Departement"), choices = c("", dep[,2]), selected = dep[1,2], width = "90%"),
                                    plotOutput("pieChart")
                      ))),
  
  tabPanel("Fit.grid",
          p("Dans cette partie nous allons prédire le taux de tweets sur toute la surface de la région Rhône Alpes. 
            Pour cela, nous allons utilisé des méthode spatiale de prédiction. Notament,le krigeage."),
          p("Ci-dessous, nous avons la cartographie de la région de rhône Alpes.
            Exports du découpage administratif français au niveau régional (contours des régions) issu d'OpenStreetMap produit 
            dans sa grande majorité à partir du cadastre.
            Ces données sont issues du crowdsourcing effectué par les contributeurs au projet OpenStreetMap et sont sous licence ODbL 
            qui impose un partage à l'identique et la mention obligatoire d'attribution doit être © les contributeurs d'OpenStreetMap sous licence ODbL."),
            fluidRow(
            column(6,
                   plotOutput("carto1")),
            column(6,
                   plotOutput("image"))
          ),
          p("Pour obtenir une estimation des densités dans le domaine d’étude, le krigeage est réalisé sur une grille régulière de points qui couvre ce domaine.
            Le choix d’une grille d’estimation dépend de l’étude et du domaine d’étude. La taille de la maille de calcul est définie selon le degré de détail souhaité. 
            La grille doit être suffisamment resserrée pour que la carte obtenue représente effectivement les estimations par krigeage. Dans cette étude, le krigeage est
            effectué sur une grille régulière couvrant toute la superficie de la région sur des pas de  
            Et nous avons en rouge les limités de la région sur la grille."),
          plotOutput("carto2"),
          p("La grille s'obtient en omitant tous les NA, aprés avoir merge la carte et la grille."),
          plotOutput("carto3"),
          p("L'analyse variographique"),
          p("Le variogramme est une fonction mathématique utilisée en géostatistique, en particulier pour le krigeage. On parle également de semivariogramme, de par le facteur 1 de sa définition.
            La fonction variographique est une fonction de distance. Elle synthétise beaucoup d’information concernant la variation conjointe de la densité à différents commune.
            C’est une étape clé située entre la description spatiale et la prévision spatiale. Le modèle le plus couramment
            utilisé (et celui utilisé pour ce stage) est le modèle Sphérique."),
          plotOutput("carto4")),
  
  tabPanel("Krigeage",
          p("Le krigeage est, en géostatistique, la méthode d’estimation linéaire garantissant le minimum de variance. 
            Le krigeage réalise l'interpolation spatiale d'une variable régionalisée par calcul de l'espérance mathématique d'une variable aléatoire, 
            utilisant l'interprétation et la modélisation du variogramme expérimental. C'est le meilleur estimateur linéaire non-biaisé ; il se fonde sur une méthode objective. 
            Il tient compte non seulement de la distance entre les données et le point d'estimation, mais également des distances entre les données deux-à-deux."),
          p("Nous observons une concentration de tweetes envoyés sur dans la zone nord-ouest. Qui s'afflaibis vers le centre et casi nulle
            vers l'est de la région."),
          plotOutput("carto5")
               ),
           
  tabPanel("Julia Code",
           p("Il nous les scripts julia à inser")),
  
  tabPanel("About",
           box(title = "About this app", includeHTML("www/include.html"), width = "100%"),
           box(width  = "100%", height = 600,
               leafletOutput("MiniMap"))
           )
)


