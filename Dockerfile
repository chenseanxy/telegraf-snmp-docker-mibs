FROM bitnami/minideb as build
WORKDIR /mibs
RUN \
    # Dependencies
    install_packages unzip wget && \
    echo "Installed build dependencies" && \
    #
    # Synology MIBs
    wget https://global.download.synology.com/download/Document/Software/DeveloperGuide/Firmware/DSM/All/enu/Synology_MIB_File.zip --no-check-certificate && \
    unzip Synology_MIB_File.zip && \
    mv Synology_MIB_File/* . && \
    rm -rf Synology_MIB_File && \
    echo "Downloaded Synology MIBs" && \
    # 
    # Dell PowerEdge MIBs
    wget http://dl.dell.com/FOLDER06009600M/1/Dell-OM-MIBS-940_A00.zip --no-check-certificate && \
    unzip Dell-OM-MIBS-940_A00.zip && \
    mv support/station/mibs/* . && \
    rm -rf support && \
    echo "Downloaded Dell PowerEdge MIBs" && \
    #
    # Cleanup
    rm -rf *.zip && \
    .

FROM nuntz/telegraf-snmp
COPY --from=build /mibs /usr/share/snmp/mibs
