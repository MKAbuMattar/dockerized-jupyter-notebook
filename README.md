# Dockerized Jupyter Notebook

This Docker container provides a Jupyter Notebook environment with some useful tools pre-installed. It's based on Ubuntu latest version and includes Node.js, Pandoc, Git, and several Python libraries.

## Requirements

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Usage

### Clone the repository

First, clone the repository to your local machine:

```bash
# clone the repository
git clone --depth 1 https://github.com/MKAbuMattar/dockerized-jupyter-notebook.git

# change directory
cd dockerized-jupyter-notebook
```

### Build the image

To build the image, run the following command:

```bash
# build the image
docker-compose build
```

### Cloud / Tool Support

This Docker container comes pre-installed with the AWS CLI, Azure CLI, Google Cloud SDK, Docker, Terraform, Helm, Kubectl command-line interfaces (CLIs), Ansible, and the Python libraries for interacting with these tools. You can use these command-line interfaces to interact with cloud services from within the Jupyter Notebook environment.

If you want to install the `Cloud / Tool` support, you need to edit the `.env` file and set the environment variables to `true`:

```bash
AWS_CLI=false
AZURE_CLI=false
GCP_CLI=false
DOCKER_CLI=false
TERRAFORM_CLI=false
HELM_CLI=false
KUBECTL_CLI=false
ANSIBLE_CLI=false
```

Change the value of the environment variables to `true` for the tools you want to install. For example, if you want to install the AWS CLI, set the `AWS_CLI` environment variable to `true`:

```bash
AWS_CLI=true
```

### Run the container

To run the container, run the following command:

```bash
# run the container
docker-compose up -d
```

This will start a container named `jupyter` that maps port `8888` to the host and mounts the `notebook` directory to the container's `/notebook` directory.

You can access the Jupyter Notebook by opening a web browser and navigating to `http://localhost:8888`. You will be navigated to the Jupyter Notebook's home page without a token, or password.

![Jupyter Notebook Home Page](./assets/jupyter-notebook-home-page.png)

### Stop the container

To stop the container, run the following command:

```bash
# stop the container
docker-compose down
```

## License

This project is licensed under the [MIT License](LICENSE)
