# flutter_geolocalizacao

Projeto que implementa Geolocalização com Flutter

## Orientações

Artigos:
[https://alligator.io/flutter/geolocator-plugin/](https://alligator.io/flutter/geolocator-plugin/)

Plugin Flutter:
[https://pub.dev/packages/geolocator](https://pub.dev/packages/geolocator)


O PASSO A PASSO DEVE VIR SEMPRE DA FONTE OFICIAL DO PLUGIN, mas abaixo segue o que foi preciso fazer na data em que este projeto foi feito.

1) Adicionar as permissões:
ANDROID:
	Adicionar no Android Manifest:



	<manifest ...
		<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
        OU 
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    Diferença: ACCESS_FINE_LOCATION é mais preciso, e ACCESS_COARSE_LOCATION dá o resultado a nível de blocos de cidades.
	    

	  

iOS:
	1) Adicionar no Info.plist

	<key>NSLocationWhenInUseUsageDescription</key>
    <string>Este aplicativo precisa acessar sua localização quando estiver aberto.</string>
	
	<key>NSLocationAlwaysUsageDescription</key>
    <string>Este aplicativo precisa acessar sua localização quando estiver em background</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Este aplicativo precisa acessar sua localização quando estiver em background</string>