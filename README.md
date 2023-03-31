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
