FROM alpine:latest

LABEL author="Laurent Etiemble"
LABEL description="Docker image to perform a scan with the Mobile Security Framework (MobSF) Web Application."

# Install required packages
RUN apk add --no-cache bash curl jq

# Define environment variables
ENV INPUT_FILE=MyApp.apk
ENV MOBSF_URL=http://host.docker.internal:8000
ENV MOBSF_API_KEY=Y@U_N!V3R_KN0W_WH0_US3_Y@U

# Create a dedicated directory to host the script
WORKDIR /app
COPY run.sh .

# Run the script
CMD ["/app/run.sh"]
