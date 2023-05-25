# Import necessary packages
import secrets
import pulumi
from pulumi_azure import storage

# Define a function to create a storage account for a static website
def make_storage_account(name, location, resource_group_name, resource_group, secure_transfer=False):
    
    # Create a new storage account with the specified parameters
    account = storage.Account(name,
        enable_https_traffic_only=secure_transfer,
        name=name,
        location=location,
        resource_group_name=resource_group_name,
        account_tier='Standard',
        account_replication_type='LRS',
        opts=pulumi.ResourceOptions(depends_on=[resource_group]),

        # Set network rules for the storage account, including virtual network and IP rules
        network_rules=storage.AccountNetworkRulesArgs(
            default_action='Deny',
            virtual_network_subnet_ids=[secrets.virtual_subnet_id],
            ip_rules=[secrets.my_global_ip]
        ),

        # Configure the storage account for static website hosting
        static_website=storage.AccountStaticWebsiteArgs(
            index_document="index.html"
        )
    )

    # Return the created storage account
    return account
