#######################
#   Musterlösung      # 
#   Jan Dix           # 
#   Friedrike Preu    #
#######################
  
# Pakete
### load additional librarires
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

# Working Directory
setwd("/home/frie/Documents/correlaid/codes_and_presentations/workshop_konstanz/")
rm(list = ls())

# R Markdown & Data Management - Aufgabenset 0
# 1. Erstelle eine Ordnerstruktur für das Projekt
# 2. Lege eine RMarkdown-Datei an für deine Notizen.
  # - Nenne den Titel deiner Datei "Correlaid Workshop @Uni Konstanz".
  # - Trage deinen Namen in das Autoren Feld ein.
# 3. Lege eine normale .R Datei an für deine Lösungen zu den Aufgabensets.


# Daten einlesen in R - Aufgabenset 1
# 1. Downloade das Repository von github (Link)
# 2. Lese die csv-Dateien ein, die mit `201704` beginnen

## Option 1 - separat einlesen

gdelt1 <- read.csv("data/20170401.csv", sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 
gdelt2 <- read.csv("data/20170402.csv", sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 
gdelt3 <- read.csv("data/20170403.csv", sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 
gdelt4 <- read.csv("data/20170404.csv", sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 

# gdelt_sub <- sample_frac(gdelt4, 0.1)
# write.table(gdelt_sub, "data/small_20170404.csv", row.names = F, sep = "\t")

gdelt <- rbind(gdelt1, gdelt2)
gdelt <- rbind(gdelt, gdelt3)
gdelt <- rbind(gdelt, gdelt4)
rm(gdelt1, gdelt2, gdelt3, gdelt4)
rm(gdelt)

## Option 2 - for loop
### define last date
n <- 4

### loop over days
for (i in 1:n) {
  path <- paste0("data/2017040", i, ".csv")
  cat(round(i / n * 100), "% fetch ", path, "\n", sep = "")
  if (!exists("gdelt")) {
    gdelt <- read.csv(path, sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 
  } else {
    gdelt <- rbind(gdelt, read.csv(path, sep = "\t", header = FALSE, stringsAsFactors = FALSE))
  }
}
rm(gdelt)

## Option 3 - lapply
paths <- paste0("data/2017040", 1:4, ".csv") # construct all the paths

# to each path, *apply* the function read.csv and return the read-in data frame 
gdelt_parts <- lapply(paths, function(path){ 
  gdelt_part <- read.csv(path, sep = "\t", header = FALSE, stringsAsFactors = FALSE, na.strings = "") 
  return(gdelt_part)
})
# we get a list of data frames that we have to "unpack" in one big dataframe
gdelt <- dplyr::bind_rows(gdelt_parts) # or plyr::ldply(gdelt_parts)
rm(gdelt_parts, paths)

save(gdelt, file = "data/aufgabenset1.rdata")

# Merging/Joins - Aufgabenset 2
# 1. Lese die Spaltennamen ein von folgendem URL: [http://bit.ly/2rb28Hi](http://bit.ly/2rb28Hi).
# 2. Lese alle Dateien in `data/codes` (außer event_codes.xlsx) ein und merge sie an den Datensatz. 
  # Beachte dabei die unterschiedlichen Dateiformate und Trennzeichen. 

## 2.1. Spaltennamen 
url <- "http://gdeltproject.org/data/lookups/CSV.header.dailyupdates.txt" # define URL 
column_names <- as.character(read.csv(url, sep = "\t", header = FALSE, stringsAsFactors = FALSE))
colnames(gdelt) <- column_names
rm(url, column_names)

## 2.2. /data/codes

### Option 1 - manuell einlesen
# Hier tatsächlich die beste Lösung, da fast jedes File so seine Eigenarten hat. ;)

# actor-type.txt
actor_type <- read.csv("data/codes/actor-type.txt", sep = "\t", stringsAsFactors = F)

# countrycodes-cameo.txt
cc_cameo <- read.csv("data/codes/countrycodes-cameo.txt", sep = ",", stringsAsFactors = F)

# die Daten sind in einer Spalte abgespeichert ohne Trennzeichen
# tidyr::separate
cc_cameo <- cc_cameo %>% tidyr::separate(CODELABEL, into = c("code", "label"), sep = 3)

# ethnic-groups.txt
# ethnic_groups <- read.csv("data/codes/ethnic-groups.txt", sep = "-") # does not work
ethnic_groups <- read.csv("data/codes/ethnic-groups.txt", sep = ",", stringsAsFactors = FALSE)
ethnic_groups <- ethnic_groups %>% 
  tidyr::separate(CODE.LABEL, into = c("code", "label"), sep = "-", extra = "merge")


## 2.3. Mergen
# merge actor types
# suffix hinzufügen um zwischen den Variablen zu Unterscheiden
gdelt <- left_join(gdelt, actor_type, by = c("Actor1Type1Code" = "CODE"))
gdelt <- left_join(gdelt, actor_type, by = c("Actor2Type1Code" = "CODE"), suffix = c("Actor1Type", "Actor2Type")) 

# merge ethnic groups
# Duplikate entfernen
# suffix hinzufügen um zwischen den Variablen zu Unterscheiden
ethnic_groups <- ethnic_groups[!duplicated(ethnic_groups$code), ]
gdelt <- left_join(gdelt, ethnic_groups, by = c("Actor1EthnicCode" = "code"))
gdelt <- left_join(gdelt, ethnic_groups, by = c("Actor2EthnicCode" = "code"), suffix = c("Actor1Ethnic", "Actor2Ethnic"))

# merge cameo dataset
# suffix hinzufügen um zwischen den Variablen zu Unterscheiden
gdelt <- left_join(gdelt, cc_cameo, by = c("Actor1CountryCode" = "code"))
gdelt <- left_join(gdelt, cc_cameo, by = c("Actor2CountryCode" = "code"), suffix = c("Actor1Country", "Actor2Country"))


save(gdelt, file = "data/aufgabenset2.rdata")

rm(list = ls())
load("data/aufgabenset2.rdata")

# Aufgabenset 3 - dplyr 
# 1. Für unsere Analyse konzentrieren wir uns auf Fälle, wo der primäre Akteur eine Institution der EU ist (Variable `Actor1Name`). 
# 2. Außerdem benötigen wir nur alle Variablen für Actor 1 und Actor 2, die Variable SQLDATE, die Eventcode-Variablen, GoldsteinScale sowie die Anzahl der Erwähnungen und der Artikel (Tipp: `?starts_with`). 

colnames(gdelt)
gdelt <- gdelt %>% 
  filter(str_detect(Actor1Name, "^EU")) %>%  # ^ means "starts with"
  select(SQLDATE, starts_with("Actor1"), starts_with("Actor2"), starts_with("Event"), starts_with("Numy"), GoldsteinScale)

save(gdelt, file = "data/aufgabenset3.rdata")

# Aufgabenset 4 - Data Manipulation 
# 1. Die Variable `EventRootCode` enhält den übergeordneten Kategoriecode für das Event. Füge dem Datensatz die entsprechende Beschreibung aus `event-codes.xlsx` hinzu. 
# 2. Erstelle eine Variable `dyad`, die die Codes beider beteiligten Akteure in jeder Zeile kombiniert. 
# 3. Wandle die Spalte `SQLDATE` in ein R Datum um (`?as.Date` und [diese Website](https://www.stat.berkeley.edu/~s133/dates.html))

## 4.1. EVENTDESCRIPTION hinzufügen 
# event-codes.xlsx 
# erst als csv abspeichern aus Excel/OpenCalc heraus
event_codes <- read.csv("data/codes/event-codes.csv", sep = ";", stringsAsFactors = FALSE)
event_codes <- event_codes %>% 
  separate(CAMEOEVENTCODE.EVENTDESCRIPTION, 
           into = c("CAMEOEVENTCODE", "EVENTDESCRIPTION"),
           sep = ",", extra = "merge")

### Option 1 - event_codes subsetten und dann joinen
# root codes sind Codes von 1-20
root_codes <- event_codes %>% 
  filter(CAMEOEVENTCODE <= 20) 
# does not work because 11-19 are also subcodes of the root code 1 

# we have to go with the CAPS feature of variable EVENTDESCRIPTION
root_codes <- event_codes %>% 
  filter(str_detect(EVENTDESCRIPTION, "^[:upper:]([:upper:])+")) 

# join
# join will fail if we don't convert CAMEOEVENTCODE to an integer
root_codes$CAMEOEVENTCODE <- as.integer(root_codes$CAMEOEVENTCODE)
gdelt <- left_join(gdelt, root_codes, by = c("EventRootCode" = "CAMEOEVENTCODE"))

### (Option 2- wenn keine Duplikate in CAMEOEVENTCODE vorhanden wären)
# Wären keine Duplikate vorhanden gewesen, hätte man sich den Subset-Schritt sparen 
# können und hätte gleich mit `left_join` joinen können. 

## 4.2. Dyade-Variable 
# Wir benutzen die beiden Variablen `Actor1Code` und `Actor2Code` und fügen sie zusammen. Unter der Annahme, dass die Codes unique sind, erhalten wir somit eine eindeutige Dyaden-ID-Variable. Für Events, in die nicht zwei Akteure involviert sind, setzen wir die Variable auf `NA`. 

### Option 1 - paste 
gdelt$dyad <- paste(gdelt$Actor1Code, gdelt$Actor2Code, sep = "-")
gdelt$dyad <- ifelse(is.na(gdelt$Actor1Code)|is.na(gdelt$Actor2Code), NA, gdelt$dyad)



## 4.3. SQLDATE
gdelt$date <- as.Date(as.character(gdelt$SQLDATE), format = "%Y%m%d")

gdelt <- gdelt %>% 
  filter(date > as.Date("2017-04-01"))


save(gdelt, file = "data/aufgabenset4.rdata")

# Aufgabenset 5 - Datenstrukturen und -formate
# 1. Erstelle einen Datensatz, der für jeden Event-Root-Code die Anzahl an Events und die mittlere Anzahl von Artikeln enthält. 
  # Behalte dabei sowohl den RootCode als auch die dazugehörige Event Description.
# 2. Erstelle einen Datensatz, der für jede Dyade und jede Eventcode - Überkategorie die Anzahl, den mittleren Goldstein Score und die Summe an Artikeln enthält. 
load("data/aufgabenset4.rdata")

## 5.1. 
events_root_code <- gdelt %>% 
  group_by(EventRootCode, EVENTDESCRIPTION) %>% 
  summarize(n_events = n(), 
            mean_articles = mean(NumArticles))

# some plotting for good measure ;) 
ggplot(events_root_code, aes(x = EVENTDESCRIPTION, y = n_events))+
  geom_bar(stat = "identity")+
  coord_flip()

ggplot(events_root_code, aes(x = n_events, y = mean_articles))+
  geom_point()

# 5.2. 
dyad_df <- gdelt %>% 
  group_by(dyad, EventRootCode) %>% 
  summarize(n_events = n(), 
            mean_goldstein = mean(GoldsteinScale), 
            sum_articles = sum(NumArticles)) %>% 
  arrange(mean_goldstein)

save(events_root_code, dyad_df, file = "data/aufgabenset5.rdata")
