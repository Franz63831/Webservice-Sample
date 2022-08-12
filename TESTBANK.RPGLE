**free
        ctl-opt  Debug Option(*NODEBUGIO)
                 BNDDIR('BANK')  ;
      //-----------------------------------------------------------------------
      // Banknamen mittels der BLZ prüfen/holen
      // in diesem Beispiel wird nur der Bankname ermittelt,
      // weitere Infos zur Bank sind abfragbar -- siehe GETBANK.
      //-----------------------------------------------------------------------

      // Main
        dcl-pr Main                         extpgm('TESTBANK');
          ppBLZ                             char(8);
        end-pr;


        dcl-pr qCmdExc                      ExtPgm('QCMDEXC');
          Cmd                               char(1000) options(*varsize) const ;
          CmdLen                            packed(15:5) const ;
        END-PR;

        dcl-PR getBank                      char(50) ExtProc;
          *N                                like(ppBLZ);
          *N                                char(1) Const options(*NOPASS);
        end-pr;

        dcl-s Info                          char(50);


      // Main
        dcl-PI Main;
          ppBLZ                             char(8  );
        end-PI;

      // Info direkt aus Responsestring auslesen
        Info = getBankName( ppBLZ );
        dsply Info;
      // Info in XML-File ausgeben und dann auslesen  
        Info = getBankName( ppBLZ: '2' );
        dsply Info;

        *inLR = *on;
        return;

      //----------------------------------------------------------------------- 
