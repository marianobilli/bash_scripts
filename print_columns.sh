#!/usr/bin/env bash



header=$(head -n 1 $1)

IFS=';'

for column in $header
do
    echo $column
done

'ApplicationCode',
 'ApplicationHostOS',
 'ApplicationHostOSManufacturer',
 'ApplicationHostOSModel',
 'ApplicationVersion',
 'ChargerSerialNumber',
 'CreateTS',
 'DeviceConnection',
 'DeviceFirmware',
 'EndOfHeatingReason',
 'EnergyConsumed',
 'ExperienceDuration',
 'ExperienceIndex',
V 'HolderSerialNumber',
V 'IsAnonymizedData',
X 'OperatorID',
 'PuffCount',
 'PuffTimestamps',
 'RawStartHeatingTime',
 'StartHeatingTime'


--- from the file ----
XX ConsumerID
XX ExternalConsumerID
HolderSerialNumber
ChargerSerialNumber
StartHeatingTime
ExperienceDuration
EnergyConsumed
PuffCount
PuffTimestamps
EndOfHeatingReason
CreateTS
RawStartHeatingTime
ExperienceIndex
ApplicationCode
ApplicationHostOS
ApplicationVersion
DeviceFirmware
XX HolderFirmware
DeviceConnection
IsAnonymizedData
ApplicationHostOSManufacturer
ApplicationHostOSModel