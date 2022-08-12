**free

         ctl-opt NoMain Debug Option(*NODEBUGIO)
                 BNDDIR('XML')  ;


      //--------------------------------------------------------------------
      // get BankInfos
      // Infos zu einer Bank (einer BLZ) auslesen; im Beispiel der Bankname
      //--------------------------------------------------------------------

         dcl-ds  DsData      qualified inz;
           Bezeichnung                           varchar(50);
           BIC                                   varchar(20);
           Ort                                   varchar(50);
           PLZ                                   varchar(10);
         end-ds;

      // Systembefehle
         dcl-PR executeCmd                       extPGM('QCMDEXC');
           Befehl                                like(cmd);
           BefehlLen                             like(cmdLen);
         end-pr;


      // SQL-Options
         exec sql set option datfmt=*iso, timfmt=*iso,
                             decmpt=*period, closqlcsr=*endactgrp,
                             COMMIT=*CHG, CLOSQLCSR=*ENDMOD;

      // Variables
         dcl-s glbTemplate                       varchar(2000);
         dcl-s glbBLZ                            varchar(8);
         dcl-s glbURL                            varchar(256);

         dcl-s Bankname                          varchar(50);

         dcl-s cmd                               char(128);
         dcl-s cmdLen                            packed(15: 5) inz(%size(cmd));


      //--------------------------------------------------------------------
      // Main
      //--------------------------------------------------------------------

         dcl-proc getBankName                    export;
           dcl-PI *N                             like(Bankname) ;
             BLZ                                 char(8);
             Typ                                 char(1) options(*NOPASS);
           end-PI;

         dcl-s  Template                         like(glbTemplate);
         dcl-s  URL                              like(glbURL);
         dcl-s  Bank                             like(BankName);
         dcl-s  Header                           varchar(256);


         // der Job muss unter CCSID 1141 laufen
           cmd = 'chgjob CCSID(1141)';
           monitor;
           executeCmd( cmd: cmdLen );
             on-Error;

           endmon;

           Header =
            '<httpHeader>+
               <header name="Content-Type" value="text/xml"/>+
             </httpHeader>';

           // kostenfreier Webservice:
           URL = 'http://www.thomas-bayer.com/axis2/services/BLZService';

           Template = getSoapTemplate(BLZ);

           // Beispiel: Response-String zuerst in Datei speichern, dann auslesen 
           if %parms >= 2 and %addr(Typ) <> *NUll and Typ = '2';
             DSData   = SoapRequestgetXMLFile(URL: Template);
             Bank = DSData.Bezeichnung;
           else;
           // Beispiel: Response-String sofort auslesen
             Bank = SoapRequestXMLString(URL: Template);
           endif;

           return Bank;

         end-proc;

      //--------------------------------------------------------------------
      // SOAP Request
      //--------------------------------------------------------------------

         dcl-proc SoapRequestXMLString;
         dcl-pi *n                               likeds(DsData) ;
           piUrl                                 like(glbUrl)      const options(*trim);
           piTemplate                            like(glbTemplate) const options(*trim);
         end-pi;

         dcl-s  offSet                           int(10);
         dcl-s  length                           int(10);
         dcl-s  BankBez                          like(BankName);

         dcl-s xmlString                         varchar(1024);

         // Daten in String-Variable schreiben und dann auslesen
         exec SQL
           set :xmlString = SYSTOOLS.HTTPPOSTCLOB(
                            :piURL,
                            null,
                            :piTemplate
               );

         offSet =  %scan('bezeichnung>': xmlString) + 12;
         length =  %scan('</ns1:bezeichnung>': xmlString);
         length -= offSet;

         BankBez = %subst(XMLString: offSet: length);
         return BankBez;

         end-Proc;

      //--------------------------------------------------------------------

      //--------------------------------------------------------------------
      // getXMLFile: GET_XML_FILE muss unter COMMIT laufen !
      //--------------------------------------------------------------------

         dcl-proc SoapRequestgetXMLFile;
           dcl-PI *n                             likeDS(DSData);
           piUrl                                 like(glbUrl)      const options(*trim);
           piTemplate                            like(glbTemplate) const options(*trim);
           end-pi;

         dcl-ds psData                           likeds(DSData) inz;

         dcl-S gFile                             SQLTYPE(CLOB_FILE);

         gFile_Name = '/home/FRANZ/bank.xml';    // <-- Verzeichnis anpassen 
         gFile_NL   = %len(%trimR(gFile_Name));
         gFile_FO   = SQFOVR;

         exec SQL
         select SYSTOOLS.HTTPPOSTCLOB(:piURL, null, :piTemplate)
           into :gFile
           from SYSIBM.SYSDUMMY1;

         exec sql
           SELECT A.*
             into :psData
             FROM XMLTABLE('*:Envelope/*:Body/*:getBankResponse/*:details'
                  PASSING CAST(XMLPARSE(
                      DOCUMENT GET_XML_FILE('/home/FRANZ/bank.xml'))  as XML)
                  COLUMNS
                  Bezeichnung    varchar(50) PATH '*:bezeichnung',
                  BIC            varchar(20) PATH '*:bic',
                  Ort            varchar(50) PATH '*:ort',
                  PLZ            varchar(10) PATH '*:plz'
          ) AS A;

           return psDATA;
         end-Proc;

      //--------------------------------------------------------------------

      //--------------------------------------------------------------------
      // Get SOAP Template
      //--------------------------------------------------------------------

         dcl-proc getSoapTemplate;
         dcl-pi *n                               like(glbTemplate) rtnparm; 
           piBLZ                                 like(glbBLZ) const options(*trim);
         end-pi;

         dcl-s LocTemplate                       like(glbTemplate);

           LocTemplate =
         //  '<?xml version="1.0" encoding="utf-8"?>+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
           +'xmlns:blz="http://thomas-bayer.com/blz/">'
           +'<soapenv:Header/>'
           +'<soapenv:Body>'
           +'<blz:getBank>'
           +'<blz:blz>§BLZ§</blz:blz>'
           +'</blz:getBank>'
           +'</soapenv:Body>'
           +'</soapenv:Envelope>';

           LocTemplate = %scanrpl('§BLZ§': piBLZ: LocTemplate);

           return LocTemplate;
         end-proc;
      //-------------------------------------------------------------------- 
