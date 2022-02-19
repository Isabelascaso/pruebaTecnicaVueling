@isTest
public with sharing class enviosServiceTest {
    @TestSetup
    static void setupData(){
        Producto__c producto = new Producto__c();
        producto.Codigo_de_producto__c = 'silla';    
    	insert producto;
    }

    @isTest
    static void doPostTest(){
        String jsonString = '{ "envios":[{"fecha_envio":"2021-09-22","id_producto":"silla","descripcion_Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/ColaEnvios/*';
        RestContext.request.requestBody = Blob.valueof(jsonString);
        RestContext.request.httpMethod = 'POST';

        Test.StartTest();
        String response = enviosService.doPost();
        Test.StopTest();
    }

    @isTest
    static void doPostProductNoExistTest(){
        String jsonString = '{ "envios":[{"fecha_envio":"2021-09-22","id_producto":"mesa","descripcion_Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/ColaEnvios/*';
        RestContext.request.requestBody = Blob.valueof(jsonString);
        RestContext.request.httpMethod = 'POST';

        Test.StartTest();
        String response = enviosService.doPost();
        Test.StopTest();
    }
}