# Webservice-Sample

In diesem Beispiele werden Bankinfos anhand der übergebenen BLZ über einen freien Webservice ermittelt und angezeigt.
Das Beispiel beschränkt sich auf den Bankname, weitere Infos zur Bank sind möglich (siehe dazu GETBANK)
Aufruf: call TestBank ('79570051')   <-- Deutsche Bank, Aschaffenburg


TESTBANK:
aufrufendes Programm, mit BLZ als Inputparameter

GETBANK:
hier wird der Bankname zur übermittelten BLZ über den freien Webservice "http://www.thomas-bayer.com/axis2/services/BLZService" erfragt.
Es handelt sich dabei um einen SOAP Web Service (detaillierte Infos unter "https://www.thomas-bayer.com")

Zwei Lösungsvarianten:
SoapRequestXMLString : Response-String wird direkt ausgelesen 
SoapRequestgetXMLFile: Response-String wird in eine CLOB-Datei ausgegeben (im IFS) und von dort ausgelesen
