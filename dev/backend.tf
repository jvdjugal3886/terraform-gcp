/*

MENTION THE BUCKET NAME HERE THAT HAS BEEN CREATED IN OUR GOOGLE CLOUD PLATFORM

*/

terraform {
  backend "gcs" {
    bucket = "  "  #Here we have to mention the name of the bucket that we are maintaing in the google cloud console under the particular project ID
    prefix = "terraform/state"
  }
}
