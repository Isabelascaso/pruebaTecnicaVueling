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

        List<Producto__c> productList = new List<Producto__c>();
        if(Schema.sObjectType.Producto__c.isAccessible()){
            productList = [SELECT id, Codigo_de_producto__c FROM Producto__c];
        }
        System.assertEquals(1, productList.size(), 'No existe el numero correcto de productos');
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

        List<Producto__c> productList = new List<Producto__c>();
        if(Schema.sObjectType.Producto__c.isAccessible()){
            productList = [SELECT id, Codigo_de_producto__c FROM Producto__c];
        }
        System.assertEquals(2, productList.size(), 'No existe el numero correcto de productos');
    }

    @isTest
    static void doPostExceptionTest(){
        String jsonString = '{ "envios":[{"fecha_envio":"2021/09/22","id_producto":"mesa","descripcion_Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
        
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/ColaEnvios/*';
        RestContext.request.requestBody = Blob.valueof(jsonString);
        RestContext.request.httpMethod = 'POST';

        Test.StartTest();
        String response = enviosService.doPost();
        Test.StopTest();

        List<Trazabilidad__c> trazabilidadList = new List<Trazabilidad__c>();
        if(Schema.sObjectType.Producto__c.isAccessible()){
            trazabilidadList = [SELECT id FROM Trazabilidad__c];
        }
        System.assertEquals(0, trazabilidadList.size(), 'NO ha entrado en la exception');
    }

    @isTest
    static void comprobarCamposObligatoriosNullTest(){
        enviosServiceRequest.envioRequest request = new enviosServiceRequest.envioRequest();
        request.fecha_envio = null;
        request.id_producto  = null;
        request.descripcion_producto  = null;
        request.cantidad  = null;
        request.almacen_destino = null;
       

        Test.StartTest();
        enviosServiceResponse.envioResponse response = enviosService.comprobarCamposObligatorios(request);
        Test.StopTest();

        
        System.assertEquals(400, response.code_result, 'No es el response esperado');
    }

    @isTest
    static void comprobarCamposObligatorioIncorrectoTest(){
        enviosServiceRequest.envioRequest request = new enviosServiceRequest.envioRequest();
        request.fecha_envio = null;
        request.id_producto  = null;
        request.descripcion_producto  = null;
        request.cantidad  = null;
        request.almacen_destino = 'null';
       

        Test.StartTest();
        enviosServiceResponse.envioResponse response = enviosService.comprobarCamposObligatorios(request);
        Test.StopTest();

        System.assertEquals(400, response.code_result, 'No es el response esperado');
    }
}