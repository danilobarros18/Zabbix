#!/bin/bash
 #######################################################################
 # Script:      serviceidsla.sh                                        #
 # Author:      Danilo Barros de Medeiros                              #
 # Contact:     Email: danilo@provtel.com.br                           #
 # Date:        2017-05-02                                             #
 # Description: Script para consultar SLA de um Servico de TI no Zabbix#
 # Requisites:  - CURL                                                 #
 #              - Python                                               #
 #######################################################################

################## VARIAVEIS #######################
                                                   #
HEADER='Content-Type: application/json'            #
URL='http://localhost/zabbix/api_jsonrpc.php'      #
USER='"Admin"'                                     #
PASSWORD='"zabbix"'                                #
SERVICEID=$1                                       #
####################################################

##Funcao de autenticacao na API do servidor Zabbix

autenticacao()
{
  JSON='{"params": {"user": '$USER',"password": '$PASSWORD'},"jsonrpc":2.0,"method":"user.login", "auth": null, "id": 1}'

  curl -s -X POST -H "$HEADER" -d "$JSON" "$URL"  | cut -d '"' -f8

}
#Variavel responsavel por armazenar o token de autenticacao da API

TOKEN=$(autenticacao) 

#Funcao que coleta o timestamp atual do servidor

timestamp() {
  date +%s
} 
DIA=$(timestamp)

#Funcao que coleta timestamp atual -7 dias

semana() {
 date -d "-7 days" +%s
}
SEMANA=$(semana)

#Funcao de consulta SLA via API do Zabbix

sla()
{
  JSON='{"params":{"serviceids":'$SERVICEID',"intervals":[{"from":'$SEMANA',"to":'$DIA'}]},"jsonrpc":"2.0","method":"service.getsla", "auth": "'$TOKEN'", "id": 1}' 

  curl -s -X POST -H "$HEADER" -d "$JSON" "$URL" | python -m json.tool | grep problemTime -A 1 | grep sla | awk '{print substr($2,1,7)}'
}

#Variavel responsavel por armazenar o valor coletado da funcao SLA

RES=$(sla) 

# Calculo necessario para apresentar o valor ao zabbix no formato aceitavel

echo ${RES/,/.}*100 | bc
