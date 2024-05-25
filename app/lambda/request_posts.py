import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError


def lambda_handler(event, context):
    # Configurações
    api_url = "https://jsonplaceholder.typicode.com/posts"
    bucket_name = "datalake-dados-dionizio"
    s3_file_key = "posts.json"

    # Fazer a requisição para a API pública
    response = requests.get(api_url)
    posts = response.json()

    # Salvar os dados em um arquivo temporário
    local_file_path = "/tmp/posts.json"
    with open(local_file_path, 'w') as f:
        json.dump(posts, f)

    s3 = boto3.client('s3')

    try:
        s3.upload_file(local_file_path, bucket_name, s3_file_key)
        return {
            'statusCode': 200,
            'body': f"Dados da API carregados com sucesso para o bucket {bucket_name} com a chave {s3_file_key}."
        }
    except FileNotFoundError:
        return {
            'statusCode': 404,
            'body': "Arquivo não encontrado."
        }
    except NoCredentialsError:
        return {
            'statusCode': 403,
            'body': "Credenciais não encontradas."
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }
