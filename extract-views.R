#clean environment
rm(list = ls())

## SUBJECT DATE
DATE_PARAM="2021-10-07"

date <- as.Date(DATE_PARAM, "%Y-%m-%d")

# install.packages('httr', 'jsonlite', 'lubridate')
library(httr)
library(aws.s3)
library(jsonlite)
library(lubridate)

#Request wikipedia API
url <- paste(
  "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia/all-access/",
  format(date, "%Y/%m/%d"), sep='')

wiki.server.response = GET(url)
wiki.response.status = status_code(wiki.server.response)
print(paste('Wikipedia API Response: ', wiki.response.status, sep=''))

wiki.response.body = content(wiki.server.response, 'text')


# Create folder
RAW_LOCATION_BASE='data/raw-views'
dir.create(file.path(RAW_LOCATION_BASE), showWarnings = TRUE, recursive = TRUE)


# Save `wiki.response.body` to the local filesystem into the folder defined 
raw.output.filename = paste("raw-views-", format(date, "%Y-%m-%d"), '.txt',
                            sep='')
raw.output.fullpath = paste(RAW_LOCATION_BASE, '/', 
                            raw.output.filename, sep='')
write(wiki.response.body, raw.output.fullpath)



#Access Keys
keyfile = list.files(path=".", pattern="accessKeys.csv", full.names=TRUE)
if (identical(keyfile, character(0))){
  stop("ERROR: AWS key file not found")
} 

keyTable <- read.csv(keyfile, header = T) # *accessKeys.csv == the CSV downloaded from AWS containing your Access & Secret keys
AWS_ACCESS_KEY_ID <- as.character(keyTable$Access.key.ID)
AWS_SECRET_ACCESS_KEY <- as.character(keyTable$Secret.access.key)

#activate
Sys.setenv("AWS_ACCESS_KEY_ID" = AWS_ACCESS_KEY_ID,
           "AWS_SECRET_ACCESS_KEY" = AWS_SECRET_ACCESS_KEY,
           "AWS_DEFAULT_REGION" = "eu-west-1") 

#Upload file to S3 bucket
BUCKET="ceu-nawal-2021" # Change this to your own bucket

put_object(file = raw.output.fullpath,
           object = paste('datalake/raw/', 
                          raw.output.filename,
                          sep = ""),
           bucket = BUCKET,
           verbose = TRUE)



## Parse the response and write the parsed string to "Bronze"

# We are extracting the top edits from the server's response
wiki.response.parsed = content(wiki.server.response, 'parsed')
top.views = wiki.response.parsed$items[[1]]$articles


# Convert the server's response to JSON lines
current.time = Sys.time() 
json.lines = ""
for (page in top.views){
  record = list(
    article = page$article[[1]],
    views = page$views,
    rank = page$rank,
    date = format(date, "%Y-%m-%d"),
    retrieved_at = current.time
  )
  
  json.lines = paste(json.lines,
                     toJSON(record,
                            auto_unbox=TRUE),
                     "\n",
                     sep='')
}

# Save the Top Edits JSON lines as a file and upload it to S3

JSON_LOCATION_BASE='data/views'
dir.create(file.path(JSON_LOCATION_BASE), showWarnings = TRUE)

json.lines.filename = paste("views-", format(date, "%Y-%m-%d"), '.json',
                            sep='')
json.lines.fullpath = paste(JSON_LOCATION_BASE, '/', 
                            json.lines.filename, sep='')

write(json.lines, file = json.lines.fullpath)

#put into my bucket
put_object(file = json.lines.fullpath,
           object = paste('datalake/views/', 
                          json.lines.filename,
                          sep = ""),
           bucket = BUCKET,
           verbose = TRUE)


