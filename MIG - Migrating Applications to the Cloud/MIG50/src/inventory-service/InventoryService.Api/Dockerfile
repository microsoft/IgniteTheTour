FROM microsoft/dotnet:2.1-sdk AS builder
WORKDIR /app

# caches restore result by copying csproj file separately
COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish --output /app/ --configuration Release --self-contained -r alpine-x64

# Stage 2
FROM microsoft/dotnet:2.1-runtime-deps-alpine
WORKDIR /app
COPY --from=builder /app .

ENV PORT 80
EXPOSE 80

ENTRYPOINT ./InventoryService.Api