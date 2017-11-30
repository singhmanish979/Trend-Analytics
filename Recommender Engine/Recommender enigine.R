# ---
# title: "recommender model"
# author: Manish Singh
# output: html_document
# ---
# ```{r}
#if(!"recommenderlab" %in% rownames(installed.packages())){
#  install.packages("recommenderlab")}

library("recommenderlab")
help(package = "recommenderlab")

set.seed(1)
# ```
# # datasets
# ```{r, include=F}
data_package <- data(package="recommenderlab")
data_package$results[,"Item"]
data("MovieLense")
MovieLense

class(MovieLense)
methods(class = class(MovieLense))
object.size(MovieLense)
object.size(as(MovieLense,"matrix"))/object.size(MovieLense)
options(digits = 2)
# Computing similraity matrix
# Collaborative filtering algorithms are based on measuring 
# the similarity between users or between items
# USer Similarity
similarity_user<- similarity(MovieLense[1:4,],method = "cosine",which="users")

class(similarity_user) # dist
as.matrix(similarity_user) # see as matrix
image(as.matrix(similarity_user),main="user similarity")

# Item Similarity
similarity_items<- similarity(MovieLense[,1:4],method = "cosine",which="items")
as.matrix(similarity_items)
image(as.matrix(similarity_items), main="Item similarity")

# Recommendationn model
recommender_model <- recommenderRegistry$get_entries(dataType="realRatingMatrix")
names(recommender_model)

library(dplyr)
lapply(recommender_model,"[[","description") %>% unlist() %>% as.matrix()
recommender_model$IBCF_realRatingMatrix$parameters %>% unlist() %>% as.matrix()

# Data Exploration
library("recommenderlab")
library("ggplot2")
data(MovieLense)
class(MovieLense)

dim(MovieLense)
class(MovieLense)
slotNames(MovieLense)
class(MovieLense@data)
dim(MovieLense@data)

# Exploring the vaues of matrix
vector_rating <- as.vector(MovieLense@data)
table_rating <- table(vector_rating) %>% print()

# remove missing values i.e 0
vector_rating <- vector_rating[vector_rating!=0]
table_rating <- table(vector_rating) %>% print()

library(ggplot2)
qplot(factor(vector_rating),fill=factor(vector_rating))+
  ggtitle("Distribution of rating")+
  xlab("User rating")+
  ylab("Rating Count")+
  guides(fill=FALSE)

# Which movies have been Viewed
view_per_movie <- colCounts(MovieLense)
view_per_movie%>% as.data.frame()%>%head()

table_views <- data.frame(
  movie = names(view_per_movie),
  View=view_per_movie
)
table_views <- table_views[order(table_views$View,decreasing = T),]

ggplot(table_views[1:6,],aes(movie,View,fill=movie))+
  geom_bar(stat = "identity")+
  theme(axis.text.x = element_text(angle = 45,hjust = 1))+
  ggtitle("Number of Views of the top movies")+
  guides(fill=FALSE)

# Finding average rating
average_rating <- colMeans(MovieLense)
# plot
qplot(average_rating,binwidth = 0.1, fill="blue") +
  ggtitle("Distribution of the average movie rating")

average_rating %>% as.data.frame()%>% head()

# filter whose is below thresold
average_ratings_relevant <- average_rating[view_per_movie > 100]
# plot
qplot(average_ratings_relevant,binwidth=0.1,fill="orange", alpha=0.5) +
  ggtitle(paste("Distribution of the relevant average ratings"))

# Visualizing the matrix
image(MovieLense,main="Heatmap of the rating matrix")

image(MovieLense[1:10, 1:15], main = "Heatmap of the first rows and columns")

min_n_movie <- quantile(rowCounts(MovieLense),0.99)%>%print()
min_n_user <- quantile(colCounts(MovieLense),0.99)%>%print()

image(MovieLense[rowCounts(MovieLense) > min_n_movie,
                 colCounts(MovieLense) > min_n_user], main = "Heatmap of the top users
      and movies")


# Data Preparation
# selecting relevant data
ratings_movies <- MovieLense[rowCounts(MovieLense)>50,
                            colCounts(MovieLense)>100] %>% print()

# visualize the top matrix
min_movies <- quantile(rowCounts(ratings_movies), 0.98)
min_users <- quantile(colCounts(ratings_movies), 0.98)

image(ratings_movies[rowCounts(ratings_movies) > min_movies,
                     colCounts(ratings_movies) > min_users], main = "Heatmap of the top
      users and movies")

average_ratings_per_user <- rowMeans(ratings_movies)

# plot
qplot(average_ratings_per_user,binwidth = 0.1) +
  ggtitle("Distribution of the average rating per user")

# Normalize data
ratings_movies_norm <- normalize(ratings_movies)
sum(rowMeans(ratings_movies_norm) > 0.00001)

# visualize the normalized matrix
image(ratings_movies_norm[rowCounts(ratings_movies_norm) > min_movies,
                          colCounts(ratings_movies_norm) > min_users], main = "Heatmap of the
top users and movies")

# Binarizing data
ratings_movies_watched <- binarize(ratings_movies,minRating=3)%>% print()

min_movies_binary <- quantile(rowCounts(ratings_movies), 0.95)
min_users_binary <- quantile(colCounts(ratings_movies), 0.95)

image(ratings_movies_watched[rowCounts(ratings_movies) > min_movies_binary,
                             colCounts(ratings_movies) > min_users_binary], main = "Heatmap of the top users and movies")

# Item based collabrative filtering
which_train <- sample(x=c(T,F),size = nrow(ratings_movies),replace = T,prob = c(0.8,0.2))
which_train %>% table()

# define traiing and test set
recc_data_train <- ratings_movies[which_train, ]%>%print()
recc_data_test <- ratings_movies[!which_train, ] %>% print()

# Item Based Collaborative filter
recommender_model <- recommenderRegistry$get_entries(dataType="realRatingMatrix")
recommender_model$IBCF_realRatingMatrix$parameters %>% as.matrix()

# recommender model
recc_model <- Recommender(data=recc_data_train,method="IBCF",parameter=list(k=30))%>%print()
recc_model %>% class()

# Exploring model
model_details <- getModel(recc_model) %>% print()

n_items_top <- 20

image(model_details$sim[1:n_items_top, 1:n_items_top],
      main = "Heatmap of the first rows and columns")

model_details$k

row_sums <- rowSums(model_details$sim > 0)
table(row_sums)

col_sums <- colSums(model_details$sim > 0) %>% as.data.frame()

qplot(col_sums,binwidth = 1) + ggtitle("Distribution of the column count")

which_max <- order(col_sums, decreasing = TRUE)[1:6]
rownames(model_details$sim)[which_max]

# Applying on test set
recc_predicted <- predict(recc_model,newdata=recc_data_test, n=6) %>% print()
class(recc_predicted)
slotNames(recc_predicted)

recc_predicted@items[[1]]

# extract the recommended movies
recc_user_1 <- recc_predicted@items[[1]]
movies_user_1 <- recc_predicted@itemLabels[recc_user_1] #%>% as.data.frame()%>% print()
movies_user_1

recc_matrix <- sapply(recc_predicted@items,function(x){
  colnames(ratings_movies)[x]
})

dim(recc_matrix)

# number_of_items <- recc_matrix %>% table()%>% factor()
number_of_items <- factor(table(recc_matrix))
chart_title <- "Distribution of the number of items for IBCF"
qplot(number_of_items) + ggtitle(chart_title)


number_of_items_sorted <- sort(number_of_items, decreasing = TRUE)
number_of_items_top <- head(number_of_items_sorted, n = 4)
table_top <- data.frame(names(number_of_items_top),
                        number_of_items_top)
table_top


# User based collabrative model
recommender_model <- recommenderRegistry$get_entries(dataType="realRatingMatrix")
recommender_model$UBCF_realRatingMatrix$parameters %>% as.matrix()

# Model
recc_model <- Recommender(data=recc_data_train,method="UBCF")%>%print()

model_details<- getModel(recc_model)
names(model_details)
model_details$data

# testing on test set
recc_predicted <- predict(object=recc_model,newdata=recc_data_test,n=6)
recc_predicted

# foreach user find recommeded movies
recc_matrix <- sapply(recc_predicted@items,function(x){
  colnames(ratings_movies)[x]
})
recc_matrix[,1]

number_of_items <- factor(table(recc_matrix))
chart_title <- "Distribution of the number of items for UBCF"
qplot(number_of_items)+ggtitle(chart_title)


# Collaborative filtering on binary data
# Binarizing data
ratings_movies_watched <- binarize(ratings_movies,minRating=1)%>% print()

# plot
qplot(rowSums(ratings_movies_watched),binwidth=10)+
  geom_vline(xintercept = mean(rowSums(ratings_movies_watched)),col="red",linetype="dashed",size=2)+
  ggtitle("Distribution of movies by user")

# Item-based collaborative filtering on binary data
recc_model <- Recommender(data=recc_data_train,method="IBCF",
                          parameter=list(method="Jaccard"))
recc_model@model %>% as.matrix()
model_details <- getModel(recc_model)

recc_predicted <- predict(object = recc_model, newdata = recc_data_test, n = 6)

recc_matrix <- sapply(recc_predicted@items, function(x){
  colnames(ratings_movies)[x]
})

recc_matrix[3]

# User-based collaborative filtering on binary data
recc_model <- Recommender(data=recc_data_train,method="UBCF",
                         parameter=list(method="Jaccard"))
recc_model@model %>% as.matrix()
model_details <- getModel(recc_model)

recc_predicted <- predict(object = recc_model, newdata = recc_data_test, n = 6)

recc_matrix <- sapply(recc_predicted@items, function(x){
  colnames(ratings_movies)[x]
})

recc_matrix[,1:4]

# ------------------------------------------------------------------------------------------ #
# ------------------------- Evaluating Recommender systems --------------------------------- #
# ------------------------------------------------------------------------------------------ #
#Preparing the data to evaluate the models
