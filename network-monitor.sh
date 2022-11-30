#!/bin/bash

retrieve_received_network() {
    echo `grep $1 /proc/net/dev | awk '{print $2}'`
}

retrieve_transmitted_network() {
    echo `grep $1 /proc/net/dev | awk '{print $10}'`
}

break_line() { echo \ ; }

show_devices() {
    echo `grep ":" /proc/net/dev | awk '{print $1}' | sed s/://`
}

echo "Escolha o tempo de duração do monitoramento (em segundos): "
read time

break_line

echo "Escolha o período de monitoramento (em segundos): "
read period

break_line

echo "Escolha dispositivo de rede a ser analisado: "
echo $(show_devices)
read device

break_line

START_TIME=$(date +%s)
(( END_TIME = START_TIME + $time ))

echo "\n[`date`]" >> file.dat
echo "# Arquivo com dados de vazão" >> file.dat
echo "# Obtidos através de monitoramento do arquivo no /proc/net/dev" >> file.dat
printf "Medições|Download|Upload\n" >> file.dat

COUNT=1

printf "$COUNT|0|0\n" >> file.dat

INITIAL_RECEIVED=$(retrieve_received_network $device)
INITIAL_TRANSMITTED=$(retrieve_transmitted_network $device)

while (( END_TIME > $(date +%s) )); do
    sleep $period
    
    CURRENT_RECEIVED=$(retrieve_received_network $device)
    CURRENT_TRANSMITTED=$(retrieve_transmitted_network $device)
    
    RECEIVED_DIFF=$((CURRENT_RECEIVED-INITIAL_RECEIVED))
    TRANSMITTED_DIFF=$((CURRENT_TRANSMITTED-INITIAL_TRANSMITTED))
    
    ((COUNT++))
    
    printf "$COUNT|$RECEIVED_DIFF|$TRANSMITTED_DIFF\n" >> file.dat
    
    INITIAL_RECEIVED=$CURRENT_RECEIVED
    INITIAL_TRANSMITTED=$CURRENT_TRANSMITTED
done

printf "`cat file.dat | column -t -s "|"`\n" > file.dat
