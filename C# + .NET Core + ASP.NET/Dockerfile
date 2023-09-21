# The `sdk` image includes .NET SDK which we need to restore and build our application
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

# Set the working directory in the image
WORKDIR /app

# Copy csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the files and build the app
COPY . ./
RUN dotnet publish -c Release -o out

RUN ls /app/out

# Use the `aspnet` image which only has the runtime installed
FROM mcr.microsoft.com/dotnet/aspnet:7.0

# Set the working directory in the image
WORKDIR /app

# Copy the build output from the `build-env` image
COPY --from=build-env /app/out .

# Open up port
EXPOSE 8080

# Start the app
ENTRYPOINT ["dotnet", "apples.dll", "--urls", "http://*:8080"]
