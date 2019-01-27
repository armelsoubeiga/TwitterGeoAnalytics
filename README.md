# Context

La géostatistique est l'étude des variables régionalisées, à la frontière entre les mathématiques et les sciences de la Terre. Son principal domaine d'utilisation a historiquement été l'estimation des gisements miniers, mais son domaine d'application actuel est beaucoup plus large et tout phénomène spatialisé peut être étudié en utilisant la géostatistique.

# TwitterGeoAnalytics

L'application Shiny est accéssible sur ce lien [TwitterGeoAnalytics App](https://armelsoubeiga.shinyapps.io/TwitterGeoAnalytics/
)

Cette analyse est restrint unique à la région de Rhône Alpes pour cette étude.

## Analyse exploratoire

Sur l'application vous avez accées à une analyse exploratoire des données tweets dans la région de Rhône Alpes. Nous avons une visualisation cartographique du taux de tweets par commune.

La partie analyse descriptive (univarié et bivarié) des données a été réalise avec le language. Qui est un language en boom démographique par sa simplicité et sa vitesse d'execussion par rapport à R et python

## Analyse variographique

Cette partie est la plus importante de la modélisation spatiale. Elle permet de construire le modéle de prédiction et de le fitter sur nos données. Elle permet également d'évaluer l'erreur de prédiction et de réajuste les hyper-parametres. Notament la fonction (sphérique, exponentiel, ...), les pas de grille, ect. En gros, l'analyse variographie permet l'entrainement du modéle de prédiction spatiale.

Dans cette étude, nous avons considére un modéle sphérique, et un pas de 1 km. Autrement dit sur chaque 1 km sur le territoire rhône alpes on prédit une estimation du nombre de tweets.

            ##analyse variographique
            coordinates(RHA)= ~longitude+latitude
            RHA <- RHA[-zerodist(RHA)[,1],] 
            tweet.vgm<- gstat::variogram(num~ 1 , RHA, cutoff=1)
            tweet.fit <- autofitVariogram(num~ 1 , RHA,model = c("Sph"))
