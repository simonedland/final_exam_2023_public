"""An Azure Python Pulumi program"""

# Import necessary packages
import pulumi
import pulumi_azure as azure 
from modules.storage_account import make_storage_account
from modules.upload_file import upload_file

# Set the number of websites to be created
#website_count = 3
config = pulumi.Config()
website_count = int(config.require('website_count'))

# Set configuration variables for the Azure resources
location = "norwayeast"
resource_group_name = "rg-pulumi-prod-norwayeast-001"
storage_account_name = "simonspulumistorage"

# Define the list of files to be uploaded to each website
files_to_uploade = [
                    ['pulumi-logo.svg','image/svg+xml'],
                    ['index.html','text/html'],
                    ['Screenshot.png','image/png']
                    ]

#create a resource group
resource_group = azure.core.ResourceGroup(resource_group_name, name=resource_group_name, location=location)


for x in range(website_count):

    # Create a storage account for each website
    account = make_storage_account(storage_account_name+f"{x}", location, resource_group_name, resource_group, secure_transfer = False)
    
    # Upload the specified files to each storage account
    for file_info in files_to_uploade:
        blob = upload_file(file_info[0], file_info[1], account.name, '$web', x, account)
