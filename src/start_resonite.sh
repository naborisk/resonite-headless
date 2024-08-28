#!/bin/sh

if [ -f ${STEAMAPPDIR}/Headless/Resonite.dll ]; then
	echo 'Resonite.dll is in the new (permanent) location, running...'
	# -LoadAssembly Libraries/ResoniteModLoader.dll を追加
	exec dotnet ${STEAMAPPDIR}/Headless/Resonite.dll -HeadlessConfig /Config/Config.json -Logs /Logs -LoadAssembly ${STEAMAPPDIR}/Headless/Libraries/ResoniteModLoader.dll 
else
	echo 'Resonite.dll not found, weird!'
	sleep 10
fi