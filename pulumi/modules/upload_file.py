# Import necessary packages
import pulumi
from pulumi_azure import storage

# Define a function to upload a file to a specified storage container
def upload_file(file_name, file_type, storage_account_name, storage_container_name, index, depends_on):
    
    # Create a new blob in the storage container using the specified parameters
    blob = storage.Blob(file_name + f"{index}",
        content_type=file_type,
        name=file_name,
        storage_account_name=storage_account_name,
        storage_container_name=storage_container_name,
        type='Block',
        
        # Set the source of the file to be uploaded from the local 'web_data' folder
        source=pulumi.FileAsset('web_data/' + file_name),
        
        # Set dependency on the provided resource
        opts=pulumi.ResourceOptions(depends_on=[depends_on])
    )
