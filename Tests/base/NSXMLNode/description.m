// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Frank Le Grand 
// Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8 
// Date: 2013-08-09 14:20:01 +0000 
// ========== End of Keysight Technologies Notice ========== 
#import "Testing.h"
/*
 * Author: Riccardo Mottola
 *  Created: 2012-07-27 14:37:14 +0000 by multix
 */

#import <Foundation/Foundation.h>

int
main(int argc, const char *argv[])
{
  NSString *filePath;
  NSString *xmlDocStr;
  NSXMLDocument *xmlDoc;
  NSXMLElement *rootElement;
  NSError *error;
  unsigned i;
  

  START_SET("NSXMLNode - descriptions")

  xmlDocStr = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><env:Envelope xmlns:env=\"http://myurl/mypath/envelope\"><InvokeStampatore xmlns=\"http://tempuri.org/\"> <Flusso><IdFlusso>DF247309-57F8-4CDB-8711-6E9DB69BCE74</IdFlusso><Sorgente>FOX/EDI</Sorgente><DataRichiesta>2012-06-26T17:00:00.717</DataRichiesta><OraRichiesta>17:00</OraRichiesta> <NumeroDocumenti>10</NumeroDocumenti><Lettera><IdCrm>FakeField</IdCrm><TipoDocumento>1001</TipoDocumento><DataDocumento>2012-06-26T14:45:08.673Z</DataDocumento><Utente>FakeUser</Utente><Priorita>Normale</Priorita><PraticaName>FakeName</PraticaName><ContentHeader> <fieldList> <Field><name>Campaign.Name</name> <value>Campagna ENP</value></Field><Field><name>Cliente.Cap</name><value>37053</value></Field></fieldList></ContentHeader></Lettera></Flusso></InvokeStampatore></env:Envelope>";
  xmlDoc = [[NSXMLDocument alloc] initWithXMLString:xmlDocStr options:0 error:error];
  
  //NSLog(@"%@", xmlDoc);
  rootElement = [xmlDoc rootElement];
  PASS(0 == [[rootElement attributes] count], "root has no attributes");
  PASS_EQUAL(
    [[[rootElement namespaces] objectAtIndex: 0] description],
    @"xmlns:env=\"http://myurl/mypath/envelope\"",
    "namespace description");
  PASS_EQUAL(
    [[[rootElement children] objectAtIndex: 0] description],
    @"<InvokeStampatore xmlns=\"http://tempuri.org/\"><Flusso><IdFlusso>DF247309-57F8-4CDB-8711-6E9DB69BCE74</IdFlusso><Sorgente>FOX/EDI</Sorgente><DataRichiesta>2012-06-26T17:00:00.717</DataRichiesta><OraRichiesta>17:00</OraRichiesta><NumeroDocumenti>10</NumeroDocumenti><Lettera><IdCrm>FakeField</IdCrm><TipoDocumento>1001</TipoDocumento><DataDocumento>2012-06-26T14:45:08.673Z</DataDocumento><Utente>FakeUser</Utente><Priorita>Normale</Priorita><PraticaName>FakeName</PraticaName><ContentHeader><fieldList><Field><name>Campaign.Name</name><value>Campagna ENP</value></Field><Field><name>Cliente.Cap</name><value>37053</value></Field></fieldList></ContentHeader></Lettera></Flusso></InvokeStampatore>",
    "child description");
  
  END_SET("NSXMLNode - descriptions")

  return 0;
}

