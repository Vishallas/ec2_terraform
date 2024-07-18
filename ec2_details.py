import boto3

custom_ec2 = boto3.client("ec2", region_name = "ap-south-1")

response = custom_ec2.describe_instances(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [
                'custom_ec2_instance',
            ]
        },
    ]
);

print(response.get("Reservations"))