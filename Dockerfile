FROM alpine:3.24

WORKDIR /app

COPY . .

CMD ["sh", "-c", "echo offensive-security"]
