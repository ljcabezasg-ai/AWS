import boto3

# Crear cliente EC2
ec2 = boto3.client('ec2')

def listar_instancias():
    response = ec2.describe_instances()

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            
            instance_id = instance['InstanceId']
            instance_type = instance['InstanceType']
            state = instance['State']['Name']
            public_ip = instance.get('PublicIpAddress', 'Sin IP pública')

            print("------")
            print(f"ID: {instance_id}")
            print(f"Estado: {state}")
            print(f"Tipo: {instance_type}")
            print(f"IP pública: {public_ip}")

if __name__ == "__main__":
    listar_instancias()