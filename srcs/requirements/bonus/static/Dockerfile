FROM debian:bookworm
RUN apt-get update && apt-get install -y python3
WORKDIR /var/www/static
COPY index.html .
EXPOSE 8081
CMD ["python3", "-m", "http.server", "8081"]
