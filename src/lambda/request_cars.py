import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError
from bs4 import BeautifulSoup


def lambda_handler(event, context):
    bucket_name = "datalake-dados-dionizio"
    s3_file_key = "cars_pricing.json"
    local_file_path = "/tmp/cars_pricing.json"

    url = 'https://napista.com.br/busca/carro-para-o-dia-a-dia'

    response = requests.get(url)

    if response.status_code == 200:

        soup = BeautifulSoup(response.content, 'html.parser')

        # Encontrar os elementos que contêm os detalhes dos carros
        car_listings = soup.find('ul', class_='sc-53e96303-0 cBddYs').find_all('li')

        cars = []

        for car in car_listings:
            name = car.find('h2', class_='sc-b35e10ef-0 hXsWso').get_text(strip=True)
            price = car.find('div', class_='sc-b35e10ef-0 klMQDM').get_text(strip=True)
            year = car.find('div', class_='sc-b35e10ef-0 kGTXHH').get_text(strip=True)
            cars.append({'Nome': name, 'Preço': price, 'Ano': year})

        with open(local_file_path, mode='w', encoding="utf-8") as f:
            json.dump(cars, f)

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


if __name__ == '__main__':
    lambda_handler(None, None)
