FROM alpine:3.20

WORKDIR /app

COPY . .

CMD ["sh", "-c", "echo offensive-security"]
