# illinois-shibboleth-sp-img

A Docker image of the Illinois Shibboleth Service Provider (SP).

## Installation and Execution

**NOTE**: The image name is arbitrary. For this document, we'll name the image `illinois-shib-sp-img`.

1. From the project directory, run:

        docker build -t illinois-shib-sp-img .

1. Run the container

        docker run illinois-shib-sp-img

## TODO

### 4 Shibboleth Configuraiton Files that Need to be Changed:

1. `sp-cert.pem`
1. `sp-key.pem`
1. `shibboleth2.xml` needs to be customized (normally user-provided).
1. `attribute-map.xml` needs to be customized (normally user-provided).

