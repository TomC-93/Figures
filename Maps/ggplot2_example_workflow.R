## Example Workflow

## Load Required Libraries

library(maptools) # For map functions
library(maps) # For map data
library(ggplot2) # For plotting
library(sf) # For plotting and manipulating spatial objects
library(rnaturalearth) # For high res country data
library(rnaturalearthdata) # Data for rnaturalearth package
library(rnaturalearthhires) # For high res region data (for Russia splitting)
library(ggforce) # For circular arrows

## Download Global Data
world <- ne_countries(scale = "medium", returnclass = "sf") # Download data on countries in mercator projection
class(world) ## Check the class of the downloaded data

## Basic Plot
ggplot(data = world) + # Tells ggplot what dataset we're using
  geom_sf() # Draws shapefiles

### Adding Colour

names(world)
table(world$continent)
ggplot(data = world) + # Tells ggplot what dataset we're using
  geom_sf() + # Draws shapefiles
  aes(fill = continent) #


### Borders, Coordinates, Colour, Legend
Palette <- c('#66c2a5','#fc8d62','#8da0cb','#e78ac3','#a6d854','#ffd92f',"#e5c494", "#b3b3b3") # Manual colour palette

theme_set(theme_bw()) ## Set the default figure background to be Black + White (provides clear white background)

ggplot(data = world) +
  geom_sf(color=NA) + # Removes country borders
  xlab("Longitude") + ylab("Latitude") + # Adds axes labels
  aes(fill = continent) +
  scale_fill_manual(values=Palette) + # Alternate colour option (based on personal construction of "Palette")
  theme(legend.position="bottom")  ## Moves legend to bottom

## Annotating Maps: Text, Lines, Arrows (Straight, Curved, Circular), and Points

# - Text: `annotate("text", x = 0, y = 0, label = "Example")`
# - Lines: `geom_segment(aes(x = 0, y = 10, xend = 0, yend =10))`
#     - Alternatively: `annotate("segment", x = 0, xend = 10, y = 0, yend = 10)`
#   - Straight Arrows: ` geom_segment(aes(x = 0, y = 10, xend = 0, yend = 10),  arrow = arrow(length = unit(0.03, "npc"), type="closed"),)`
# - Circles: `geom_circle(aes(x0 = 0, y0 = 0, r = 7.5))`
#   - Circle Segments: `geom_arc(aes(x0 = 0, y0 = 0, r = 7.5,start = 0, end = 2 * pi),)`
#    - Circular Arrows: `geom_arc(aes(x0 = 19, y0 = 7, r = 7.5,start = -0.2*pi, end = -1.8 * pi),arrow = arrow(length = unit(0.03, "npc"), type="closed",angle=45, ends="last"))`
# - Curved Lines: `geom_curve(aes(x = -20, y = -20, xend = -30, yend = -30), angle = 90)`
#   - Curved Arrows: `geom_curve(aes(x = -55, y = -35, xend = 5, yend = -20), arrow = arrow(length = unit(0.03, "npc"), type="closed"), angle = 90)`
# - Points: `geom_point(x= 50, y=50)`
# - Rectangles: `annotate("rect", xmin = -10, xmax = 10, ymin = -10, ymax = 10, alpha = .2)`
#     - "alpha" argument indicates opacity. A value of 0.2 will produce a mostly see through rectangle

ggplot(data = world) +
  geom_sf(color=NA) +
  aes(fill = continent) +
  scale_fill_manual(values=Palette) +
  theme(legend.position="bottom", axis.text.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.x=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank(),
        axis.title.y=element_blank()) +
  annotate("text", x = 135, y = -25, label = "Oceania") +
  annotate("text", x = 135, y = -45, label = "Oceania", fontface = 'bold') +
  annotate("text", x = 135, y = -35, label = "Oceania", fontface = 'italic') +
  geom_curve(aes(x = 114, y = -20, xend = 56, yend = 17),arrow = arrow(length = unit(0.03, "npc"),
                                                                       type="closed"), colour = "#000000", size = 0.8, angle = 90, curvature = -0.2) +
  geom_segment(aes(x = 150, y = -20, xend = 179, yend = 10), colour = "#000000", size = 0.8) +
  # Line segments can create the illusion that arrows wrap across map boundaries.
  geom_segment(aes(x = -179, y = 11, xend = -145, yend = 55), arrow = arrow(length = unit(0.03, "npc"),
                                                                            type="closed"), colour = "#000000", size = 0.8) +
  geom_arc(aes(x0 = 17, y0 = 43, r = 7.5, start = -0.2*pi, end = -1.8 * pi),
           arrow = arrow(length = unit(0.03, "npc"), type="closed", angle=45, ends="last"),
           colour = "#000000", size = 0.55) +
  annotate("rect", xmin = -57, xmax = -49, ymin = 0, ymax = 8, color="red", alpha=0)

## Modifying Countries

### Fix French Guiana - it is currently displayed as part of mainland France. Needs splitting.
FRA <- world[73,] # Isolate France row
split <- st_cast(FRA, "POLYGON") # Split multipolygon into many polygons

ggplot(data = FRA) + # Plot confirming correct polygons (row 3 is French Guiana, row 10 is mainland France)
  geom_sf() +
  ggtitle("French Territories") # Adding a Title

ggplot(data = split[3,]) + # Plot confirming correct polygons (row 3 is French Guiana, row 10 is mainland France)
  geom_sf() +
  ggtitle("French\nGuiana") # Adding a Title - "\n" adds a line break

guy <- split[3,] # Isolate polygon for French Guiana
FRA_main <- split[10,] # Isolate polygon for mainland France

## Give French Guiana new values to differentiate it from mainland France.
guy$admin <- "French Guiana"
guy$continent <- "South America"

## We can now replace all French polygons on main map with these 2 separate polygons. Other territories (e.g. French Polynesia) are too small to be viewed so can be ignored (depending on your map's purpose).
baguetteless <- world[world$sovereignt!="France",]
world2 <- rbind(baguetteless, FRA_main, guy)

## Remove Antarctica & Seven seas (open ocean)
world2 <- world2[world2$continent!="Antarctica",]
world2 <- world2[world2$continent!="Seven seas (open ocean)",]

ggplot(data = world2) +
  geom_sf(color=NA) +
  aes(fill = continent) +
  scale_fill_manual(values=Palette) +
  theme(legend.position="bottom", axis.text.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.x=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank(),
        axis.title.y=element_blank())

### Splitting Russia

## Download High Resolution Country Data
rus <- ne_states(country = "Russia", returnclass = "sf")

ggplot(data = rus) + # Plot confirming Russian polygons work
  geom_sf()

rus$continent <- NA
names(rus)

rus[rus$region=="Central"|rus$region=="Volga"|rus$region=="Northwestern",85] <- "Europe"
rus[rus$region=="Far Eastern"|rus$region=="Siberian"|rus$region=="Urals",85] <- "Asia"

norus <- world2[world2$sovereignt!="Russia",]

names(norus)

## Need to match colnames of rus and norus for rbind to work.
norus <- norus[,c(18,55,64)] # Remove extraneous columns
colnames(norus) <- c("Name","Continent","geometry") # Rename remaining columns consistently
rus <- rus[,c(9,85,84)]
colnames(rus) <- c("Name","Continent","geometry")

world3 <- rbind(norus,rus)
world3 <- world3[!is.na(world3$Continent),] # Remove any NAs

ggplot(data = world3) +
  geom_sf(color=NA) +
  aes(fill = Continent) +
  scale_fill_manual(values=Palette) +
  theme(legend.position="bottom", axis.text.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.x=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank(),
        axis.title.y=element_blank())

