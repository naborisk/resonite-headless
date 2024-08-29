#!/bin/sh

if [ -f ${STEAMAPPDIR}/Headless/Resonite.dll ]; then
	echo 'Resonite.dll is in the new (permanent) location, running...'
	cd ${STEAMAPPDIR}/Headless/
	exec dotnet ./Resonite.dll -LoadAssembly ./Libraries/ResoniteModLoader.dll -HeadlessConfig /Config/Config.json -Logs /Logs
else
	echo 'Resonite.dll not found, weird!'
	sleep 10
fi