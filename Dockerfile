FROM bitnami/minideb as build
WORKDIR /mibs
RUN \
    # Add non-free -> weldpua2008/docker-net-snmp
    export DEBIAN_RELEASE=$(awk -F'[" ]' '/VERSION=/{print $3}'  /etc/os-release | tr -cd '[[:alnum:]]._-' ) && \
    echo "deb http://httpredir.debian.org/debian ${DEBIAN_RELEASE} non-free" >> /etc/apt/sources.list && \
    #
    # Dependencies
    install_packages unzip wget snmp-mibs-downloader && \
    echo "Installed build dependencies" && \
    wwget() { wget --no-check-certificate --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" "$@"; } && \
    #
    # Synology MIBs
    wwget https://global.download.synology.com/download/Document/Software/DeveloperGuide/Firmware/DSM/All/enu/Synology_MIB_File.zip && \
    unzip Synology_MIB_File.zip && \
    mv Synology_MIB_File/* . && \
    rm -rf Synology_MIB_File && \
    echo "Downloaded Synology MIBs" && \
    # 
    # Dell PowerEdge MIBs
    wwget http://dl.dell.com/FOLDER06009600M/1/Dell-OM-MIBS-940_A00.zip && \
    unzip Dell-OM-MIBS-940_A00.zip && \
    mv support/station/mibs/* . && \
    rm -rf support && \
    echo "Downloaded Dell PowerEdge MIBs" && \
    #
    # MikroTik MIB
    # https://wiki.mikrotik.com/wiki/Manual:SNMP#Management_information_base_.28MIB.29
    # Link up to date as of 2021-11 (last updated 2020-09)
    wwget https://box.mikrotik.com/f/a41daf63d0c14347a088/?dl=1 -O MIKROTIK-MIB.txt && \
    #
    # Cleanup
    rm -rf *.zip && \
    .

FROM telegraf
COPY --from=build /usr/share/snmp/mibs /usr/share/snmp/mibs
COPY --from=build /mibs /usr/share/snmp/mibs
