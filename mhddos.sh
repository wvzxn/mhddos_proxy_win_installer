#!/bin/bash
cd
cd ./Desktop/mhddos-proxy-py
checkfolder () {
    if [ -d ./mhddos_proxy ]; then
        cd mhddos_proxy
        clear
    else
        git clone https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git
        cd mhddos_proxy
        if [ "`arch`" = "x86_64" ]; then python -m pip install -r requirements.txt; else python3 -m pip install -r requirements.txt; fi
        clear
    fi
}
checkfolder
if [ "`arch`" = "x86_64" ]; then source <(curl -s https://raw.githubusercontent.com/wazxn/mhddos-proxy-py/main/command); else source <(curl -s https://raw.githubusercontent.com/wazxn/mhddos-proxy-py/main/command3); fi
exit