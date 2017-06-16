# toy datasets

# slide 34 ff.
respondents <- data.frame(id = 1:7, sex = c("male", rep(c("male", "female"), 3)), country = c("DE", "DE", "CH", "CH", "CH", "FR", "AU"), stringsAsFactors = F)
countries <- data.frame(country = c("DE", "CH", "UK", "AU"), bip_capita = c(48111, 59561, 42481, 48005), stringsAsFactors = F)



# slide 44
df <- countrycode::countrycode_data[1:10, c("iso2c", "country.name.en")]

# slide 46
ger <- c("GERMANY", "GERMNY", "GREMANY", "GERMANY", "GERMANY")

# slide 55
data(mtcars)


# slide 59
x_fac <- factor(c("a", "b", "b", "a"))


# slide 64
df <- data.frame(x = rep(c("strongly agree", "agree", "neither", 
                           "disagree", "strongly disagree"), 2), 
                 stringsAsFactors = TRUE)

# slide 65
tmp <- data.frame(x = levels(df$x), x_num = 1:5)

# slide 70
df_wide <- data.frame(name = c("Mary", "John", "Andy"), 
                      weight2005 = c(65, 75, 80), 
                      weight2006 = c(64, 80, 75))

# slide 71
df_long <- data.frame(name = rep(c("Mary", "John", "Andy"), each = 2), 
                      year = rep(c(2005:2006), times = 3),
                      weight = c(65, 64, 75, 80, 80, 75))

# slide 93
data(mtcars)
