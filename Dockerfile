#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

RUN ln -s /lib/x86_64-linux-gnu/libdl-2.24.so /lib/x86_64-linux-gnu/libdl.so
RUN apt-get update \
 && apt-get install -y --allow-unauthenticated \
 libc6-dev \
 libgdiplus \
 libx11-dev \
 && rm -rf /var/lib/apt/lists/*
ENV DISPLAY :99

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["FastReport/FastReportDemo1.csproj", "FastReport/"]
RUN dotnet restore "./FastReport/./FastReportDemo1.csproj"
COPY . .
WORKDIR "/src/FastReport"
RUN dotnet build "./FastReportDemo1.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./FastReportDemo1.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Install required packages
RUN apt-get update && apt-get install -y fontconfig

# Copy the font file to the container
COPY ./Font/* /usr/local/share/fonts/truetype/

# Refresh the font cache
RUN fc-cache -f -v

ENTRYPOINT ["dotnet", "FastReportDemo1.dll"]