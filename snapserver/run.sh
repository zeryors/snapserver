#!/usr/bin/env bashio

#mkdir -p /share/snapfifo

if [ "$(bashio::config 'spotify.bypass_apresolve')" = true ]; then
    echo "0.0.0.0	apresolve.spotify.com" >> /etc/hosts
fi

config=/etc/snapserver.conf
spotify_credentials_file=$(bashio::config 'spotify.cache_dir')/credentials.json

if ! [ -d $(bashio::config 'spotify.cache_dir') ]; then
    mkdir $(bashio::config 'spotify.cache_dir')
fi

if ! bashio::fs.file_exists '/etc/snapserver.conf'; then
    touch /etc/snapserver.conf ||
        bashio::exit.nok "Could not create snapserver.conf file on filesystem"
fi
bashio::log.info "Populating snapserver.conf..."

# Server Config
echo "[server]" > "${config}"

# Threads
if bashio::config.has_value 'server.threads'; then
    echo "threads = $(bashio::config 'server.threads')" >> "${config}"
fi

# Datadir
if bashio::config.has_value 'server.datadir'; then
    echo "datadir = $(bashio::config 'server.datadir')" >> "${config}"
fi

# Stream Config
echo "[stream]" >> "${config}"

# Spotify
echo $(bashio::config 'spotify.credentials') > ${spotify_credentials_file}
echo -n "stream = spotify:///librespot?name=Spotify" >> "${config}"
echo -n "&devicename=$(bashio::config 'spotify.device_name')" >> "${config}"
echo -n "&bitrate=$(bashio::config 'spotify.bitrate')" >> "${config}"
echo -n "&volume=$(bashio::config 'spotify.volume')" >> "${config}"
echo -n "&cache=$(bashio::config 'spotify.cache_dir')" >> "${config}"
echo -n "&cache-size-limit=$(bashio::config 'spotify.cache_size_limit')" >> "${config}"
echo -n "&autoplay=true" >> "${config}"
#echo -n "&wd_timeout=3600" >> "${config}" # This might lead to uneccesary restarts if there are no log lines by librespot
echo -n "&params=--disable-discovery" >> "${config}"
echo "" >> "${config}"

# Other streams
if bashio::config.has_value 'stream.streams'; then
    echo "stream = $(bashio::config 'stream.streams')" >> "${config}"
fi

# Stream bis and ter # it was in the fork, idk wtf it's for
if bashio::config.has_value 'stream.bis'; then
    echo "$(bashio::config 'stream.bis')" >> "${config}"
fi
if bashio::config.has_value 'stream.ter'; then
    echo "$(bashio::config 'stream.ter')" >> "${config}"
fi

# Buffer
if bashio::config.has_value 'stream.buffer'; then
    echo "buffer = $(bashio::config 'stream.buffer')" >> "${config}"
fi

# Codec
if bashio::config.has_value 'stream.codec'; then
    echo "codec = $(bashio::config 'stream.codec')" >> "${config}"
fi

# Muted
if bashio::config.has_value 'stream.send_to_muted'; then
    echo "send_to_muted = $(bashio::config 'stream.send_to_muted')" >> "${config}"
fi

# Sampleformat
if bashio::config.has_value 'stream.sampleformat'; then
    echo "sampleformat = $(bashio::config 'stream.sampleformat')" >> "${config}"
fi

# HTTP
echo "[http]" >> "${config}"

if bashio::config.has_value 'http.enabled'; then
    echo "enabled = $(bashio::config 'http.enabled')" >> "${config}"
fi

if bashio::config.has_value 'http.bind_to_address'; then
    echo "bind_to_address = $(bashio::config 'http.bind_to_address')" >> "${config}"
fi

# HTTP document root
echo "doc_root = /usr/share/snapserver/snapweb/" >> "${config}"

# TCP
echo "[tcp]" >> "${config}"

if bashio::config.has_value 'tcp.enabled'; then
    echo "enabled = $(bashio::config 'tcp.enabled')" >> "${config}"
fi

# Logging
echo "[logging]" >> "${config}"

if bashio::config.has_value 'logging.enabled'; then
    echo "debug = $(bashio::config 'logging.enabled')" >> "${config}"
fi

bashio::log.info "Starting SnapServer..."
exec snapserver
